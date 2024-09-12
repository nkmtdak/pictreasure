Rails.application.routes.draw do
  devise_for :users
  get '/photos', to: 'photos#index'
  root 'challenges#index'
  
  
  resources :challenges do
    resources :photos, only: [:index, :new, :create, :show, :destroy] do
      collection do
        post 'similarity_check'
      end
    end
  end

  # API用のルーティング（必要な場合）
  # namespace :api do
  #   namespace :v1 do
  #     resources :challenges, only: [:index, :show] do
  #       resources :photos, only: [:create] do
  #         collection do
  #           post 'similarity_check'
  #         end
  #       end
  #     end
  #   end
  # end
end