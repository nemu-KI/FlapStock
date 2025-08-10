class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :configure_permitted_parameters, if: :devise_controller?

  # Punditのエラーハンドリング
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :company_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :company_name])
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  def after_sign_in_path_for(resource_or_scope)
    dashboard_path
  end

  private

  def user_not_authorized
    flash[:alert] = "この操作を実行する権限がありません。"
    redirect_back(fallback_location: root_path)
  end
end
