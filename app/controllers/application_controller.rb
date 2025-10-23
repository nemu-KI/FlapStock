# frozen_string_literal: true

# ApplicationController
class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :check_guest_session_timeout

  # Punditのエラーハンドリング
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name company_name])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name company_name])
  end

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  def after_sign_in_path_for(_resource_or_scope)
    dashboard_path
  end

  private

  # ゲストセッションのタイムアウトチェック
  def check_guest_session_timeout
    return unless session[:guest_mode]

    handle_guest_session_timeout
  end

  def handle_guest_session_timeout
    return set_guest_session_start if session[:guest_session_start].nil?

    return unless guest_session_expired?

    clear_guest_session
    redirect_to root_path, alert: 'お試しモードのセッションがタイムアウトしました。再度ログインしてください。'
  end

  def set_guest_session_start
    session[:guest_session_start] = Time.current.to_s
  end

  def guest_session_expired?
    Time.current - Time.parse(session[:guest_session_start]) > 2.hours
  end

  def clear_guest_session
    session[:guest_mode] = false
    session[:guest_session_start] = nil
    sign_out(current_user)
  end

  def user_not_authorized
    flash[:alert] = 'この操作を実行する権限がありません。'
    redirect_back(fallback_location: root_path)
  end
end
