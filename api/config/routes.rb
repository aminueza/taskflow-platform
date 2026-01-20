Rails.application.routes.draw do
  # Swagger API documentation
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  # Health check endpoint
  get '/health', to: 'health#index'

  # =====================
  # API Routes (for React Frontend)
  # =====================
  namespace :api do
    namespace :v1 do
      resources :users, only: [:index, :show, :create, :update, :destroy]
      resources :tasks, only: [:index, :show, :create, :update, :destroy] do
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
