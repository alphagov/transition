Transition::Application.routes.draw do
  root to: 'organisations#index'

  resources :style, only: [:index]
  resources :glossary, only: [:index]

  match '/400' => 'errors#error_400'
  match '/404' => 'errors#error_404'
  match '/422' => 'errors#error_422'
  match '/500' => 'errors#error_500'

  resources :hosts, only: [:index]

  resources :organisations, only: [:show, :index]

  get 'mappings/find_global', to: 'mappings#find_global'
  get 'hits', to: 'hits#summary_global'
  get 'hits/redirects', to: 'hits#category_global', defaults: { category: 'redirects' }
  get 'hits/errors',    to: 'hits#category_global', defaults: { category: 'errors' }
  get 'hits/archives',  to: 'hits#category_global', defaults: { category: 'archives' }

  resources :sites, only: [:show] do

    get 'mappings/find', as: 'mapping_find'
    resources :mappings, except: [:new, :create, :destroy] do
      resources :versions, only: [:index]

      collection do
        get  'new_multiple'
        post 'new_multiple_confirmation'
        post 'create_multiple'

        post 'edit_multiple'
        post 'update_multiple'

        get 'filter'
      end
    end

    resources :batches, only: [:show]

    resources :hits, only: [:index] do
      collection do
        get 'summary'
        get 'redirects', to: 'hits#category', defaults: { category: 'redirects' }
        get 'errors',    to: 'hits#category', defaults: { category: 'errors' }
        get 'archives',  to: 'hits#category', defaults: { category: 'archives' }
      end
    end
  end
end
