# frozen_string_literal: true

# Users::SessionsController
# Deviseのセッションコントローラーをカスタマイズ
module Users
  # SessionsController
  class SessionsController < Devise::SessionsController
    before_action :set_ogp_tags, only: [:new]

    private

    def set_ogp_tags
      @page_title = 'FlapStock'
      @page_description = 'FlapStockは、効率的な在庫管理を実現するWebアプリケーションです。'
    end
  end
end
