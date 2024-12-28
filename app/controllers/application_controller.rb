class ApplicationController < ActionController::Base
  # before_action :raise_call

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :vpn, :country_id, streaming_service_ids: []])

    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :vpn, :country_id, streaming_service_ids: []])
  end

  def raise_call
    raise
  end
end
