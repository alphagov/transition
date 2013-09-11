Transition::Application.routes.draw do
  get "sites/show"

  root to: 'organisations#index'

  resources :organisations, only: [:show, :index]
  resources :sites, only: [:show]
end
