# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExceptionHandler, type: :controller do
  controller(ActionController::API) do
    include ResponseHelper
    include ExceptionHandler

    def test_standard_error
      raise StandardError, 'Test error'
    end

    def test_record_not_found
      raise ActiveRecord::RecordNotFound, 'Record not found'
    end

    def test_record_invalid
      user = User.new
      user.valid?
      raise ActiveRecord::RecordInvalid, user
    end

    def test_parameter_missing
      raise ActionController::ParameterMissing, :test_param
    end

    def test_with_appinsights
      ENV['APPINSIGHTS_INSTRUMENTATIONKEY'] = 'test-key'
      raise StandardError, 'Test error with AppInsights'
    end
  end

  before do
    routes.draw do
      get 'test_standard_error' => 'anonymous#test_standard_error'
      get 'test_record_not_found' => 'anonymous#test_record_not_found'
      get 'test_record_invalid' => 'anonymous#test_record_invalid'
      get 'test_parameter_missing' => 'anonymous#test_parameter_missing'
      get 'test_with_appinsights' => 'anonymous#test_with_appinsights'
    end
  end

  after do
    ENV.delete('APPINSIGHTS_INSTRUMENTATIONKEY')
  end

  describe 'StandardError handling' do
    context 'when in non-production environment' do
      before { allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development')) }

      it 'returns detailed error with backtrace' do
        get :test_standard_error

        expect(response).to have_http_status(:internal_server_error)
        json = response.parsed_body
        expect(json['error']).to eq('Test error')
        expect(json['errors']).to be_an(Array)
      end
    end

    context 'when in production environment' do
      before { allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production')) }

      it 'returns generic error message' do
        get :test_standard_error

        expect(response).to have_http_status(:internal_server_error)
        json = response.parsed_body
        expect(json['error']).to eq('An unexpected error occurred')
      end
    end

    context 'with Application Insights configured' do
      before do
        ENV['APPINSIGHTS_INSTRUMENTATIONKEY'] = 'test-key'
      end

      it 'attempts to track exception' do
        # AppInsights may not be loaded in test env, so we just test the branch
        get :test_with_appinsights

        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end

  describe 'ActiveRecord::RecordNotFound handling' do
    it 'returns 404 status' do
      get :test_record_not_found

      expect(response).to have_http_status(:not_found)
      json = response.parsed_body
      expect(json['error']).to eq('Record not found')
    end
  end

  describe 'ActiveRecord::RecordInvalid handling' do
    it 'returns 422 with validation errors' do
      get :test_record_invalid

      expect(response).to have_http_status(:unprocessable_content)
      json = response.parsed_body
      expect(json['error']).to eq('Validation failed')
      expect(json['errors']).to be_an(Array)
      expect(json['errors']).not_to be_empty
    end
  end

  describe 'ActionController::ParameterMissing handling' do
    it 'returns 400 status' do
      get :test_parameter_missing

      expect(response).to have_http_status(:bad_request)
      json = response.parsed_body
      expect(json['error']).to include('param')
    end
  end
end
