Rails.application.routes.draw do
  get 'dashboards/index'
  devise_for :users
  get 'home/index'
  root 'dashboards#index'
end
