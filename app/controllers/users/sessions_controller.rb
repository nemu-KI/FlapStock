# frozen_string_literal: true

# Users::SessionsController
# Deviseのセッションコントローラーをカスタマイズ
module Users
  # SessionsController
  class SessionsController < Devise::SessionsController
    before_action :set_ogp_tags, only: [:new]

    private

    def set_ogp_tags
      @page_title = 'ログイン - FlapStock'
      @page_description = 'FlapStockの在庫管理システムにログインしてください。'
    end
  end
end
