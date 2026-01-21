# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuditLog, type: :model do
  describe 'validations' do
    subject { build(:audit_log) }

    it { is_expected.to validate_presence_of(:action) }
    it { is_expected.to validate_presence_of(:resource_type) }

    it 'is valid with valid attributes' do
      audit_log = build(:audit_log)
      expect(audit_log).to be_valid
    end

    it 'is invalid without an action' do
      audit_log = build(:audit_log, action: nil)
      expect(audit_log).not_to be_valid
      expect(audit_log.errors[:action]).to include("can't be blank")
    end

    it 'is invalid without a resource_type' do
      audit_log = build(:audit_log, resource_type: nil)
      expect(audit_log).not_to be_valid
      expect(audit_log.errors[:resource_type]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user).optional }
    it { is_expected.to belong_to(:resource).optional }

    it 'is associated with a user' do
      user = create(:user)
      audit_log = create(:audit_log, user: user)
      expect(audit_log.user).to eq(user)
    end
  end

  describe 'factory' do
    it 'has valid factory' do
      expect(build(:audit_log)).to be_valid
    end

    it 'creates audit log with create action trait' do
      audit_log = create(:audit_log, :create_action)
      expect(audit_log.action).to eq('create')
    end

    it 'creates audit log with update action trait' do
      audit_log = create(:audit_log, :update_action)
      expect(audit_log.action).to eq('update')
    end

    it 'creates audit log with delete action trait' do
      audit_log = create(:audit_log, :delete_action)
      expect(audit_log.action).to eq('delete')
    end
  end
end
