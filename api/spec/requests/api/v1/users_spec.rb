# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  let(:valid_attributes) do
    {
      user: {
        username: 'testuser',
        email: 'test@example.com',
        password: 'password123'
      }
    }
  end

  let(:invalid_attributes) do
    {
      user: {
        username: '',
        email: 'invalid_email'
      }
    }
  end

  describe 'GET /api/v1/users' do
    before { create_list(:user, 3) }

    it 'returns all users' do
      get '/api/v1/users'

      expect(response).to have_http_status(:ok)
      expect(json_response.size).to eq(3)
    end

    it 'paginates results' do
      get '/api/v1/users', params: { page: 1, per_page: 2 }

      expect(response).to have_http_status(:ok)
      expect(json_response.size).to eq(2)
    end
  end

  describe 'GET /api/v1/users/:id' do
    let(:user) { create(:user) }

    context 'when user exists' do
      it 'returns the user' do
        get "/api/v1/users/#{user.id}"

        expect(response).to have_http_status(:ok)
        expect(json_response['id']).to eq(user.id)
        expect(json_response['username']).to eq(user.username)
      end
    end

    context 'when user does not exist' do
      it 'returns not found' do
        get '/api/v1/users/999999'

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/users' do
    context 'with valid parameters' do
      it 'creates a new user' do
        expect {
          post '/api/v1/users', params: valid_attributes
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
      end

      it 'returns the created user' do
        post '/api/v1/users', params: valid_attributes

        expect(json_response['username']).to eq('testuser')
        expect(json_response['email']).to eq('test@example.com')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a user' do
        expect {
          post '/api/v1/users', params: invalid_attributes
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error messages' do
        post '/api/v1/users', params: invalid_attributes

        expect(json_response['errors']).to be_present
      end
    end

    context 'with duplicate email' do
      before { create(:user, email: 'test@example.com') }

      it 'returns conflict error' do
        post '/api/v1/users', params: valid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to include('email')
      end
    end
  end

  describe 'PATCH /api/v1/users/:id' do
    let(:user) { create(:user) }
    let(:new_attributes) { { user: { username: 'updated_username' } } }

    context 'with valid parameters' do
      it 'updates the user' do
        patch "/api/v1/users/#{user.id}", params: new_attributes

        expect(response).to have_http_status(:ok)
        expect(user.reload.username).to eq('updated_username')
      end
    end

    context 'with invalid parameters' do
      it 'returns unprocessable entity' do
        patch "/api/v1/users/#{user.id}", params: invalid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /api/v1/users/:id' do
    let!(:user) { create(:user) }

    it 'soft deletes the user' do
      delete "/api/v1/users/#{user.id}"

      expect(response).to have_http_status(:no_content)
      expect(user.reload.deleted_at).to be_present
    end

    it 'returns not found for non-existent user' do
      delete '/api/v1/users/999999'

      expect(response).to have_http_status(:not_found)
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end

