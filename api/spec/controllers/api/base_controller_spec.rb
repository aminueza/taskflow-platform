# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::BaseController, type: :controller do
  controller(described_class) do
    def test_record_not_found
      raise ActiveRecord::RecordNotFound, 'User not found'
    end

    def test_record_invalid
      user = User.new
      user.valid?
      raise ActiveRecord::RecordInvalid, user
    end

    def test_standard_error
      raise StandardError, 'Something went wrong'
    end
  end

  before do
    routes.draw do
      get 'test_record_not_found' => 'api/base#test_record_not_found'
      get 'test_record_invalid' => 'api/base#test_record_invalid'
      get 'test_standard_error' => 'api/base#test_standard_error'
    end
  end

  describe 'error handling' do
    describe 'RecordNotFound' do
      it 'returns 404 with error message' do
        get :test_record_not_found

        expect(response).to have_http_status(:not_found)
        json = response.parsed_body
        expect(json['error']).to eq('Record not found')
        expect(json['message']).to include('User not found')
      end
    end

    describe 'RecordInvalid' do
      it 'returns 422 with validation errors' do
        get :test_record_invalid

        expect(response).to have_http_status(:unprocessable_content)
        json = response.parsed_body
        expect(json['error']).to eq('Validation failed')
        expect(json['details']).to be_an(Array)
      end
    end

    describe 'StandardError' do
      it 'returns 500 with error message' do
        get :test_standard_error

        expect(response).to have_http_status(:internal_server_error)
        json = response.parsed_body
        expect(json['error']).to eq('Internal server error')
        expect(json['message']).to eq('Something went wrong')
      end
    end
  end
end
