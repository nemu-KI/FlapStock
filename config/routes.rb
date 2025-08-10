Rails.application.routes.draw do
  resources :items, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    resources :stock_movements, only: [:index, :new, :create]
  end
  resources :stock_movements, only: [:index, :show, :edit, :update, :destroy]
  resources :categories, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :locations, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :suppliers, only: [:index, :show, :new, :create, :edit, :update, :destroy]

  # ダッシュボード
  get 'dashboards/index'
  get 'dashboard', to: 'dashboards#index'

  # 認証
  devise_for :users

  # LetterOpenerWeb（開発環境のみ）
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end



  # ルート
  root 'dashboards#index'
end
