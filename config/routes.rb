Rails.application.routes.draw do
  devise_for :users
  root 'challenges#index'

  resources :challenges do
    resources :photos, only: [:index, :new, :create, :show, :destroy] do
      collection do
        post 'similarity_check'
      end
    end
  end

  resources :photos, only: [] do
    member do
      get 'check_similarity'
    end
  end

  # API用のルーティング
  namespace :api do
    namespace :v1 do
      resources :challenges, only: [:index, :show] do
        resources :photos, only: [:create] do
          collection do
            post 'similarity_check'
          end
        end
      end
    end
  end
end