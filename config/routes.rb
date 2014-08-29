Transition::Application.routes.draw do
  mount GovukAdminTemplate::Engine, at: '/style-guide'
  root to: 'organisations#index'

  resources :style, only: [:index]
  resources :glossary, only: [:index]

  match '/400' => 'errors#error_400', via: [:get, :post]
  match '/404' => 'errors#error_404', via: [:get, :post]
  match '/422' => 'errors#error_422', via: [:get, :post]
  match '/500' => 'errors#error_500', via: [:get, :post]

  resources :hosts, only: [:index]

  resources :organisations, only: [:show, :index]

  get 'mappings/find_global', to: 'mappings#find_global'
  get 'hits', to: 'hits#universal_summary'
  get 'hits/redirects', to: 'hits#universal_category', defaults: { category: 'redirects' }
  get 'hits/errors',    to: 'hits#universal_category', defaults: { category: 'errors' }
  get 'hits/archives',  to: 'hits#universal_category', defaults: { category: 'archives' }

  get 'leaderboard', to: 'leaderboard#index'

  resources :sites, only: [:show] do

    get 'mappings/find', as: 'mapping_find'
    resources :mappings, only: [:index, :edit, :update] do
      resources :versions, only: [:index]

      collection do
        post 'edit_multiple'
        post 'update_multiple'

        get 'filter'

        resources :bulk_add_batches, only: [:new] do
          collection do
            post 'new_multiple_confirmation'
          end

          member do
            post 'import'
          end
        end

        resources :import_batches, only: [:new, :create] do
          member do
            get 'preview'
            post 'import'
          end
        end
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

  namespace :admin do
    resources :whitelisted_hosts, only: [:index, :new, :create]
  end
end
