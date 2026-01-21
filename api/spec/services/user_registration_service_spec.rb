# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserRegistrationService do
  describe '#call' do
    let(:valid_params) do
      {
        username: 'newuser',
        email: 'newuser@example.com',
        password: 'password123'
      }
    end

    let(:invalid_params) do
      {
        username: '',
        email: 'invalid'
      }
    end

    context 'with valid parameters' do
      it 'creates a new user' do
        expect do
          described_class.new(valid_params).call
        end.to change(User, :count).by(1)
      end

      it 'returns the created user' do
        user = described_class.new(valid_params).call

        expect(user).to be_a(User)
        expect(user).to be_persisted
      end

      it 'queues a welcome email' do
        expect do
          described_class.new(valid_params).call
        end.to change(UserMailerWorker.jobs, :size).by(1)
      end
    end

    context 'with invalid parameters' do
      it 'raises an error' do
        expect do
          described_class.new(invalid_params).call
        end.to raise_error(UserRegistrationService::RegistrationError)
      end

      it 'does not create a user' do
        expect do
          described_class.new(invalid_params).call
        rescue UserRegistrationService::RegistrationError
          # expected
        end.not_to change(User, :count)
      end

      it 'does not queue a welcome email' do
        expect do
          described_class.new(invalid_params).call
        rescue UserRegistrationService::RegistrationError
          # expected
        end.not_to change(UserMailerWorker.jobs, :size)
      end
    end

    context 'when email already exists' do
      before { create(:user, email: 'newuser@example.com') }

      it 'raises an error' do
        expect do
          described_class.new(valid_params).call
        end.to raise_error(UserRegistrationService::RegistrationError)
      end
    end
  end
end
