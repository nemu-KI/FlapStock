Rails.application.routes.draw do
  resources :items
  get 'dashboards/index'
  devise_for :users
  get 'home/index'
  root 'dashboards#index'
end
