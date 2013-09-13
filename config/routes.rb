Transition::Application.routes.draw do
  root to: 'organisations#index'

  resources :organisations, only: [:show, :index]
  resources :sites, only: [:show] do
    resources :mappings, only: [:index, :edit, :update]
  end
end
