# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe UserMailerWorker, type: :worker do
  before do
    ActionMailer::Base.deliveries.clear
  end

  describe '#perform' do
    let(:user) { create(:user) }

    it 'sends welcome email to user' do
      expect do
        described_class.new.perform(user.id, 'welcome')
      end.to change { ActionMailer::Base.deliveries.count }.by(1)

      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to include(user.email)
      expect(mail.subject).to eq('Welcome to TaskFlow!')
    end

    it 'handles missing user gracefully' do
      expect do
        described_class.new.perform(999_999)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'sidekiq options' do
    it 'uses mailers queue' do
      expect(described_class.sidekiq_options['queue']).to eq('mailers')
    end

    it 'has retry enabled' do
      expect(described_class.sidekiq_options['retry']).to eq(3)
    end
  end

  describe 'job enqueuing' do
    it 'enqueues the job' do
      Sidekiq::Testing.fake! do
        expect do
          described_class.perform_async(1)
        end.to change(described_class.jobs, :size).by(1)
      end
    end
  end
end
