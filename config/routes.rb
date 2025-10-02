# frozen_string_literal: true

Rails.application.routes.draw do
  # 静的ページ
  get 'privacy_policy', to: 'static_pages#privacy_policy'
  get 'terms_of_service', to: 'static_pages#terms_of_service'
  resources :items, only: %i[index show new create edit update destroy] do
    resources :stock_movements, only: %i[index new create]
  end
  resources :stock_movements, only: %i[index show edit update destroy]
  resources :categories, only: %i[index new create edit update destroy]
  resources :locations, only: %i[index new create edit update destroy]
  resources :suppliers, only: %i[index show new create edit update destroy]

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
