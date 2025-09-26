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
      @page_description = 'FlapStockは、効率的な在庫管理を実現するWebアプリケーションです。'
    end
  end
end
