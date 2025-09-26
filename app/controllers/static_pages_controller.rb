# frozen_string_literal: true

# StaticPagesController
class StaticPagesController < ApplicationController
  # プライバシーポリシーと利用規約は認証不要でアクセス可能
  skip_before_action :authenticate_user!, only: %i[privacy_policy terms_of_service]

  def privacy_policy
    @page_title = 'プライバシーポリシー - FlapStock'
    @page_description = 'FlapStockの個人情報の取り扱いについて説明します。'

    # ログイン状態に応じてレイアウトとビューを切り替え
    if user_signed_in?
      render layout: 'application'
    else
      render 'privacy_policy_public', layout: 'public'
    end
  end

  def terms_of_service
    @page_title = '利用規約 - FlapStock'
    @page_description = 'FlapStockの利用規約について説明します。'

    # ログイン状態に応じてレイアウトとビューを切り替え
    if user_signed_in?
      render layout: 'application'
    else
      render 'terms_of_service_public', layout: 'public'
    end
  end
end
