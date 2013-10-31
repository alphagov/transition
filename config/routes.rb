Transition::Application.routes.draw do
  root to: 'organisations#index'

  resources :style, only: [:index]

  resources :organisations, only: [:show, :index]
  resources :sites, only: [] do

    get 'mappings/find', as: 'mapping_find'
    resources :mappings, except: [:destroy] do
      resources :versions, only: [:index]
    end

    resources :hits, only: [:index] do
      collection do
        get 'summary'
        get 'errors'
        get 'archives'
        get 'redirects'
        get 'other'
      end
    end
  end
end
