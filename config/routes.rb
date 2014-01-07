Transition::Application.routes.draw do
  root to: 'organisations#index'

  resources :style, only: [:index]

  resources :hosts, only: [:index]

  resources :organisations, only: [:show, :index]
  resources :sites, only: [:show] do

    get 'mappings/find', as: 'mapping_find'
    resources :mappings, except: [:destroy] do
      resources :versions, only: [:index]

      collection do
        get  'new_multiple'
        post 'new_multiple_confirmation'
        post 'create_multiple'

        post 'edit_multiple'
        post 'update_multiple'
      end
    end

    resources :hits, only: [:index] do
      collection do
        get 'summary'
        get 'redirects', to: 'hits#category', defaults: { category: 'redirects' }
        get 'errors',    to: 'hits#category', defaults: { category: 'errors' }
        get 'archives',  to: 'hits#category', defaults: { category: 'archives' }
        get 'other',     to: 'hits#category', defaults: { category: 'other' }
      end
    end
  end
end
