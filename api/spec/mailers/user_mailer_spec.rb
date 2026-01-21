# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe '#welcome_email' do
    let(:user) { create(:user, email: 'test@example.com', username: 'testuser') }
    let(:mail) { described_class.welcome_email(user) }

    it 'renders the subject' do
      expect(mail.subject).to eq('Welcome to TaskFlow!')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([user.email])
    end

    it 'assigns @user' do
      expect(mail.body.encoded).to match(user.username)
    end
  end

  describe '#password_reset_email' do
    let(:user) { create(:user, email: 'test@example.com', username: 'testuser') }
    let(:mail) { described_class.password_reset_email(user) }

    it 'renders the subject' do
      expect(mail.subject).to eq('Password Reset Instructions')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([user.email])
    end

    it 'assigns @user' do
      expect(mail.body.encoded).to match(user.username)
    end
  end
end
