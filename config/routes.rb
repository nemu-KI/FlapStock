# frozen_string_literal: true

Rails.application.routes.draw do
  # 静的ページ
  get 'privacy_policy', to: 'static_pages#privacy_policy'
  get 'terms_of_service', to: 'static_pages#terms_of_service'
  resources :items, only: %i[index show new create edit update destroy] do
    resources :stock_movements, only: %i[index new create]
    collection do
      get :autocomplete
    end
  end
  resources :stock_movements, only: %i[index show edit update destroy]
  resources :categories, only: %i[index new create edit update destroy]
  resources :locations, only: %i[index new create edit update destroy]
  resources :suppliers, only: %i[index show new create edit update destroy] do
    collection do
      get :autocomplete
    end
  end

  # ダッシュボード
  get 'dashboards/index'
  get 'dashboard', to: 'dashboards#index'

  # ガイドページ（新規ユーザー向け）
  get 'guide', to: 'guide#index'
  get 'guide/getting-started', to: 'guide#getting_started'
  get 'guide/master-data', to: 'guide#master_data'
  get 'guide/items', to: 'guide#items'
  get 'guide/stock', to: 'guide#stock'
  get 'guide/dashboard', to: 'guide#dashboard'

  # ヘルプページ（既存ユーザー向け）
  get 'help', to: 'help#index'
  get 'help/faq', to: 'help#faq'
  get 'help/troubleshooting', to: 'help#troubleshooting'
  get 'help/contact', to: 'help#contact'

  # お問い合わせフォーム
  get 'contact', to: 'contacts#new'
  post 'contact', to: 'contacts#create'
  get 'contact/confirm', to: 'contacts#confirm'
  post 'contact/complete', to: 'contacts#complete'
  get 'contact/complete', to: 'contacts#complete'

  # 在庫アラート
  get 'alerts', to: 'alerts#index'
  get 'alerts/stock', to: 'alerts#stock'

  # 発注メール作成
  resources :order_emails, only: %i[new create] do
    collection do
      post :preview        # プレビュー画面
      get :select_items    # 物品選択画面
    end
  end

  # 発注履歴
  resources :orders, only: %i[index show update destroy]

  # 設定
  get 'settings', to: 'company_settings#index'
  get 'settings/company', to: 'company_settings#show'
  get 'settings/edit', to: 'company_settings#edit'
  patch 'settings', to: 'company_settings#update'
  # 表示設定（ユーザー個別設定）
  patch 'settings/display', to: 'company_settings#update_display'
  # アラート設定（会社単位設定）
  patch 'settings/alerts', to: 'company_settings#update_alerts'
  # ユーザー設定（ユーザー個別設定）
  patch 'settings/user', to: 'company_settings#update_user'
  # ユーザー権限設定（管理者のみ）
  patch 'settings/users/:user_id/role', to: 'company_settings#update_user_role'
  patch 'settings/users/:user_id/reset_password', to: 'company_settings#reset_user_password'
  delete 'settings/users/:user_id', to: 'company_settings#delete_user'

  # 認証
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  # LetterOpenerWeb（開発環境のみ）
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  # ルート
  root 'dashboards#root'
end
