Rails.application.routes.draw do
  root 'challenges#index'
  
  devise_for :users
  
  resources :challenges do
    resources :photos, only: [:new, :create]
  end
end
