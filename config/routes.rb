Transition::Application.routes.draw do
  root to: 'organisations#index'
  
  resources :style, only: [:index]
  
  resources :organisations, only: [:show, :index]
  resources :sites, only: [] do
    resources :mappings, except: [:destroy] do
      resources :versions, only: [:index]
    end

    resources :hits, only: [:index] do
      collection do
        get 'summary'
      end
    end
  end
end
