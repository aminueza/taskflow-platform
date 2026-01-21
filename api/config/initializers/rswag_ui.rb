# frozen_string_literal: true

Rswag::Ui.configure do |c|
  # List the Swagger endpoints that you want to be documented
  c.openapi_endpoint '/api-docs/v1/swagger.yaml', 'TaskFlow API V1'
end
