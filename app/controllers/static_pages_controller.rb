# frozen_string_literal: true

# StaticPagesController
class StaticPagesController < ApplicationController
  # プライバシーポリシーは認証不要でアクセス可能
  skip_before_action :authenticate_user!, only: [:privacy_policy]

  def privacy_policy
    # ログイン状態に応じてレイアウトとビューを切り替え
    if user_signed_in?
      render layout: 'application'
    else
      render 'privacy_policy_public', layout: 'public'
    end
  end
end
