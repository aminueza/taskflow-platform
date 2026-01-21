# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResponseHelper, type: :controller do
  controller(ActionController::API) do
    include described_class

    def test_render_success
      render_success({ name: 'Test' }, message: 'Success message')
    end

    def test_render_created
      render_created({ id: 1 })
    end

    def test_render_error
      render_error('Error message', errors: ['Error 1'], status: :bad_request)
    end

    def test_render_bad_request
      render_bad_request('Bad request')
    end

    def test_render_unauthorized
      render_unauthorized('Unauthorized')
    end

    def test_render_forbidden
      render_forbidden
    end

    def test_render_not_found
      render_not_found
    end

    def test_render_unprocessable_entity
      render_unprocessable_entity('Validation failed', errors: ['Field required'])
    end

    def test_render_conflict
      render_conflict('Conflict occurred')
    end
  end

  before do
    routes.draw do
      get 'test_render_success' => 'anonymous#test_render_success'
      get 'test_render_created' => 'anonymous#test_render_created'
      get 'test_render_error' => 'anonymous#test_render_error'
      get 'test_render_bad_request' => 'anonymous#test_render_bad_request'
      get 'test_render_unauthorized' => 'anonymous#test_render_unauthorized'
      get 'test_render_forbidden' => 'anonymous#test_render_forbidden'
      get 'test_render_not_found' => 'anonymous#test_render_not_found'
      get 'test_render_unprocessable_entity' => 'anonymous#test_render_unprocessable_entity'
      get 'test_render_conflict' => 'anonymous#test_render_conflict'
    end
  end

  describe '#render_success' do
    it 'renders success response with data' do
      get :test_render_success

      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json['success']).to be true
      expect(json['data']).to eq('name' => 'Test')
      expect(json['message']).to eq('Success message')
      expect(json['meta']).to have_key('timestamp')
    end
  end

  describe '#render_created' do
    it 'renders created response' do
      get :test_render_created

      expect(response).to have_http_status(:created)
      json = response.parsed_body
      expect(json['success']).to be true
      expect(json['data']).to eq('id' => 1)
      expect(json['message']).to eq('Resource created successfully')
    end
  end

  describe '#render_error' do
    it 'renders error response' do
      get :test_render_error

      expect(response).to have_http_status(:bad_request)
      json = response.parsed_body
      expect(json['success']).to be false
      expect(json['error']).to eq('Error message')
      expect(json['errors']).to eq(['Error 1'])
    end
  end

  describe '#render_bad_request' do
    it 'renders bad request response' do
      get :test_render_bad_request

      expect(response).to have_http_status(:bad_request)
      json = response.parsed_body
      expect(json['error']).to eq('Bad request')
    end
  end

  describe '#render_unauthorized' do
    it 'renders unauthorized response' do
      get :test_render_unauthorized

      expect(response).to have_http_status(:unauthorized)
      json = response.parsed_body
      expect(json['error']).to eq('Unauthorized')
    end
  end

  describe '#render_forbidden' do
    it 'renders forbidden response' do
      get :test_render_forbidden

      expect(response).to have_http_status(:forbidden)
      json = response.parsed_body
      expect(json['error']).to eq('Access denied')
    end
  end

  describe '#render_not_found' do
    it 'renders not found response' do
      get :test_render_not_found

      expect(response).to have_http_status(:not_found)
      json = response.parsed_body
      expect(json['error']).to eq('Resource not found')
    end
  end

  describe '#render_unprocessable_entity' do
    it 'renders unprocessable entity response' do
      get :test_render_unprocessable_entity

      expect(response).to have_http_status(:unprocessable_content)
      json = response.parsed_body
      expect(json['error']).to eq('Validation failed')
      expect(json['errors']).to eq(['Field required'])
    end
  end

  describe '#render_conflict' do
    it 'renders conflict response' do
      get :test_render_conflict

      expect(response).to have_http_status(:conflict)
      json = response.parsed_body
      expect(json['error']).to eq('Conflict occurred')
    end
  end
end
