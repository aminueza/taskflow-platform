# frozen_string_literal: true

Rswag::Api.configure do |c|
  # Specify a root folder where Swagger JSON files are located
  c.openapi_root = Rails.root.join('swagger').to_s
end
