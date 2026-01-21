# frozen_string_literal: true

# CORS configuration for API-only mode
# Allows React frontend to communicate with Rails API

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Development: Allow specific localhost ports
    origins 'http://localhost:5173',
            'http://localhost:8080',
            'http://localhost:3000',
            'http://127.0.0.1:5173',
            'http://127.0.0.1:8080',
            'http://127.0.0.1:3000'

    resource '*',
             headers: :any,
             methods: %i[get post put patch delete options head],
             credentials: true,
             expose: ['Authorization']
  end

  # Production: Add frontend URL if specified
  if ENV['FRONTEND_URL'].present?
    allow do
      origins ENV['FRONTEND_URL']

      resource '/api/*',
               headers: :any,
               methods: %i[get post put patch delete options head],
               credentials: true,
               expose: ['Authorization']
    end
  end
end
