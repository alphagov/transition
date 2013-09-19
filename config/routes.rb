Transition::Application.routes.draw do
  root to: 'organisations#index'

  resources :organisations, only: [:show, :index]
  resources :sites, only: [:show] do
    resources :mappings, only: [:index, :edit, :update] do
      resources :versions, only: [:index]
    end
  end
end
