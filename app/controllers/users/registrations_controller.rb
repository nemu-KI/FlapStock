# frozen_string_literal: true

# Users::RegistrationsController
# Deviseの登録コントローラーをカスタマイズ
module Users
  # RegistrationsController
  class RegistrationsController < Devise::RegistrationsController
    before_action :set_ogp_tags, only: [:new]

    private

    def set_ogp_tags
      @page_title = '新規登録 - FlapStock'
      @page_description = 'FlapStockの在庫管理システムに新規登録してください。'
    end
  end
end
