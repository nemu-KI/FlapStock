Rails.application.routes.draw do
  resources :items, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  resources :categories, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :locations, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :suppliers, only: [:index, :show, :new, :create, :edit, :update, :destroy]

  # ダッシュボード
  get 'dashboards/index'
  get 'dashboard', to: 'dashboards#index'

  # 認証
  devise_for :users

  # ホーム
  get 'home/index'

  # ルート
  root 'dashboards#index'
end
