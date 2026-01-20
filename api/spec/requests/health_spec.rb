# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Health Check', type: :request do
  describe 'GET /health' do
    it 'returns healthy status' do
      get '/health'

      expect(response).to have_http_status(:ok)
      expect(json_response['status']).to eq('healthy')
    end

    it 'includes timestamp' do
      get '/health'

      expect(json_response['timestamp']).to be_present
    end

    it 'includes database status' do
      get '/health'

      expect(json_response['checks']).to include('database')
    end

    it 'includes redis status' do
      get '/health'

      expect(json_response['checks']).to include('redis')
    end
  end

  describe 'GET /health/ready' do
    it 'returns ready status when all services are up' do
      get '/health/ready'

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /health/live' do
    it 'returns alive status' do
      get '/health/live'

      expect(response).to have_http_status(:ok)
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end

