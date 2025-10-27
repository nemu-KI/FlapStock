# frozen_string_literal: true

# Users::RegistrationsController
# Deviseの登録コントローラーをカスタマイズ
module Users
  # RegistrationsController
  class RegistrationsController < Devise::RegistrationsController
    before_action :set_ogp_tags, only: [:new]

    def create
      # 利用規約とプライバシーポリシーの同意チェック
      unless params[:privacy_policy_agreement].present? && params[:terms_of_service_agreement].present?
        build_resource(sign_up_params)
        resource.validate
        resource.errors.add(:base, '利用規約とプライバシーポリシーへの同意が必要です')
        render :new, status: :unprocessable_entity
        return
      end

      super
    end

    private

    def set_ogp_tags
      @page_title = '新規登録 - FlapStock'
      @page_description = 'FlapStockは、効率的な在庫管理を実現するWebアプリケーションです。'
    end
  end
end
