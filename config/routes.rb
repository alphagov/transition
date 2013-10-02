Transition::Application.routes.draw do
  root to: 'organisations#index'
  
  resources :style, only: [:index]
  
  resources :organisations, only: [:show, :index]
  resources :sites, only: [] do
    resources :mappings, except: [:destroy] do
      resources :versions, only: [:index]
    end
  end
end
