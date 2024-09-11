Rails.application.routes.draw do
  root 'challenges#index'
  
  devise_for :users
  
  resources :challenges do
    resources :photos, only: [:new, :create] do
      collection do
        post 'similarity_check'
      end
    end
  end
end
