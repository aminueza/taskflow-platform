# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Auditable, type: :model do
  # Create a test model that includes Auditable
  let(:test_class) do
    Class.new(ApplicationRecord) do
      self.table_name = 'users'
      include Auditable

      def self.name
        'TestAuditableModel'
      end
    end
  end

  let(:instance) { test_class.new(username: 'test', email: 'test@example.com', password: 'password123') }

  describe 'associations' do
    it 'has many audit_logs' do
      expect(test_class.reflect_on_association(:audit_logs)).to be_present
      expect(test_class.reflect_on_association(:audit_logs).macro).to eq(:has_many)
    end
  end

  describe 'callbacks' do
    it 'has after_commit callback for log_change' do
      callbacks = test_class._commit_callbacks.select do |cb|
        cb.filter == :log_change
      end
      expect(callbacks).not_to be_empty
    end
  end

  describe '#transaction_state' do
    context 'when record is new' do
      it 'returns :create' do
        instance.save!
        expect(instance.send(:transaction_state)).to eq(:create)
      end
    end

    context 'when record is updated' do
      it 'returns :update' do
        instance.save!
        instance.update!(username: 'updated')
        expect(instance.send(:transaction_state)).to eq(:update)
      end
    end

    context 'when record is destroyed' do
      it 'returns :destroy' do
        instance.save!
        instance.destroy!
        expect(instance.send(:transaction_state)).to eq(:destroy)
      end
    end
  end

  describe '#log_change' do
    before do
      allow(AuditLog).to receive(:create!)
    end

    context 'when creating a record' do
      it 'logs the create action' do
        allow(AuditLog).to receive(:create!)
        instance.save!
        expect(AuditLog).to have_received(:create!).with(
          hash_including(action: 'created')
        )
      end
    end

    context 'when error occurs during audit logging' do
      before do
        allow(AuditLog).to receive(:create!).and_raise(StandardError.new('Audit failed'))
        allow(Rails.logger).to receive(:error)
      end

      it 'logs the error and does not raise' do
        allow(Rails.logger).to receive(:error)
        expect { instance.save! }.not_to raise_error
        expect(Rails.logger).to have_received(:error).with(
          hash_including(
            event: 'audit_log_failed',
            error: 'Audit failed'
          )
        )
      end
    end
  end
end
