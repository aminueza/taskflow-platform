# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Protect from CSRF attacks for web requests
  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def record_not_found
    respond_to do |format|
      format.html { redirect_to root_path, alert: 'Record not found' }
      format.json { render json: { error: 'Record not found' }, status: :not_found }
    end
  end
end
