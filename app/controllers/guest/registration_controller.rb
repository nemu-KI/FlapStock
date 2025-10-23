# frozen_string_literal: true

# ゲストから正式登録への誘導
module Guest
  # ゲストユーザーの登録処理を管理するコントローラー
  class RegistrationController < ApplicationController
    before_action :authenticate_guest!

    def new
      # ゲスト情報を取得してフォームに表示
      @company = Company.find(session[:guest_company_id])
      @user = User.find(session[:guest_user_id])
    end

    def create
      # 正式登録ページにリダイレクト（ゲスト情報を引き継ぎ）
      redirect_to new_user_registration_path(guest_data: {
                                               company_name: params[:company_name],
                                               user_name: params[:user_name],
                                               email: params[:email]
                                             })
    end

    private

    def authenticate_guest!
      return if session[:guest_mode] && session[:guest_user_id]

      redirect_to guest_login_path, alert: 'お試しモードにログインしてください。'
    end
  end
end
