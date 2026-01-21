Rails.application.routes.draw do
  # Swagger API documentation
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  # Health check endpoints
  get '/health', to: 'health#index'
  get '/health/live', to: 'health#live'
  get '/health/ready', to: 'health#ready'

  # =====================
  # API Routes (for React Frontend)
  # =====================
  namespace :api do
    namespace :v1 do
      resources :users, only: %i[index show create update destroy]
      resources :tasks, only: %i[index show create update destroy] do
        member do
          patch :toggle_status
        end
      end

      post '/auth', to: 'authentication#create'
    end
  end

  # Metrics endpoint (for Prometheus scraping)
  get '/metrics', to: 'metrics#index'
end
