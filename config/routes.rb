Rails.application.routes.draw do
  get 'photos/new'
  get 'photos/create'
  get 'challenges/index'
  get 'challenges/show'
  get 'challenges/new'
  get 'challenges/create'
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
