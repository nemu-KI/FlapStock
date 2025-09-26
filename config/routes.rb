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

  # 認証
  devise_for :users

  # LetterOpenerWeb（開発環境のみ）
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  # ルート
  root 'dashboards#index'
end
