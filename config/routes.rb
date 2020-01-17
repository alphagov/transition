Rails.application.routes.draw do
  mount GovukAdminTemplate::Engine, at: '/style-guide'
  root to: 'authentication#index'

  resources :style, only: [:index]
  resources :glossary, only: [:index]

  match '/400' => 'errors#error_400', via: %i[get post]
  match '/403' => 'errors#error_403', via: %i[get post]
  match '/404' => 'errors#error_404', via: %i[get post]
  match '/422' => 'errors#error_422', via: %i[get post]
  match '/500' => 'errors#error_500', via: %i[get post]

  get 'auth/auth0/callback', to: 'authentication#create'
  get '/auth/gds/sign_out', to: 'authentication#destroy'

  resources :hosts, only: [:index]

  resources :organisations, except: [:destroy]

  get 'mappings/find_global', to: 'mappings#find_global'
  get 'hits', to: 'hits#universal_summary'
  get 'hits/category', to: 'hits#universal_category'

  get 'leaderboard', to: 'leaderboard#index'

  resources :sites, except: [:destroy] do
    get 'mappings/find', as: 'mapping_find'
    resources :mappings, only: %i[index edit update] do
      resources :versions, only: [:index]

      collection do
        post 'edit_multiple'
        post 'update_multiple'

        get 'filter'

        resources :bulk_add_batches, only: %i[new create] do
          member do
            get 'preview'
            post 'import'
          end
        end

        resources :import_batches, only: %i[new create] do
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
        get 'category'
      end
    end
  end

  namespace :admin do
    resources :whitelisted_hosts, only: %i[index new create]
  end
end
