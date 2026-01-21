# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:username) }
    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to validate_uniqueness_of(:username) }
    it { is_expected.to validate_length_of(:username).is_at_least(3).is_at_most(50) }
    it { is_expected.to allow_value('user@example.com').for(:email) }
    it { is_expected.not_to allow_value('invalid_email').for(:email) }

    it 'validates case-insensitive uniqueness of email' do
      create(:user, email: 'test@example.com')
      user2 = build(:user, email: 'TEST@EXAMPLE.COM')

      expect(user2).not_to be_valid
      expect(user2.errors[:email]).to include('has already been taken')
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:tasks).dependent(:destroy) }
    it { is_expected.to have_many(:audit_logs).dependent(:destroy) }
  end

  describe 'callbacks' do
    it 'downcases email before save' do
      user = create(:user, email: 'TEST@EXAMPLE.COM')
      expect(user.reload.email).to eq('test@example.com')
    end
  end

  describe 'scopes' do
    let!(:active_user) { create(:user) }
    let!(:deleted_user) { create(:user, deleted_at: Time.current) }

    describe '.active' do
      it 'returns only active users' do
        expect(described_class.active).to include(active_user)
        expect(described_class.active).not_to include(deleted_user)
      end
    end

    describe '.recent' do
      it 'returns users ordered by created_at desc' do
        newer_user = create(:user)
        expect(described_class.recent.first).to eq(newer_user)
      end
    end
  end

  describe '#soft_delete!' do
    let(:user) { create(:user) }

    it 'sets deleted_at timestamp' do
      expect { user.soft_delete! }.to change(user, :deleted_at).from(nil)
    end

    it 'does not destroy the record' do
      user.soft_delete!
      expect(described_class.find_by(id: user.id)).to be_present
    end
  end

  describe '#active?' do
    it 'returns true for active users' do
      user = create(:user)
      expect(user).to be_active
    end

    it 'returns false for deleted users' do
      user = create(:user, deleted_at: Time.current)
      expect(user).not_to be_active
    end
  end

  describe '#generate_token' do
    let(:user) { create(:user) }

    it 'generates a JWT token' do
      token = user.generate_token
      expect(token).to be_a(String)
      expect(token.split('.').length).to eq(3) # JWT has 3 parts
    end

    it 'includes user_id in payload' do
      token = user.generate_token
      secret = Rails.application.credentials.secret_key_base || Rails.application.secret_key_base
      payload = JWT.decode(token, secret, true, algorithm: 'HS256').first
      expect(payload['user_id']).to eq(user.id)
    end

    it 'sets expiration time' do
      token = user.generate_token(expires_in: 1.hour)
      secret = Rails.application.credentials.secret_key_base || Rails.application.secret_key_base
      payload = JWT.decode(token, secret, true, algorithm: 'HS256').first
      expect(payload['exp']).to be_within(5).of(1.hour.from_now.to_i)
    end
  end
end
