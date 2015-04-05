class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

 before_action :configure_permitted_parameters, if: :devise_controller?

 protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << [:name, :address, :zip]
    devise_parameter_sanitizer.for(:account_update) << [:name, :address, :phone]
  end

  # Check if user has permission to see the pin (by location)
  def validate_location
    unless Pin.find(params[:id]).zip == current_user.zip
      flash[:notice] = "Sorry, you don't have permission to see this pin!"
      redirect_to root_path
    end
  end
end
