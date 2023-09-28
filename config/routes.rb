Rails.application.routes.draw do
  mount GovukPublishingComponents::Engine, at: "/component-guide" if Rails.env.development?

  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }
  get "/healthcheck/ready", to: GovukHealthcheck.rack_response(
    GovukHealthcheck::ActiveRecord,
    GovukHealthcheck::SidekiqRedis,
  )

  mount GovukAdminTemplate::Engine, at: "/style-guide"
  root to: "organisations#index"

  resources :style, only: [:index]
  resources :glossary, only: [:index]

  match "/400" => "errors#error_400", via: %i[get post]
  match "/403" => "errors#error_403", via: %i[get post]
  match "/404" => "errors#error_404", via: %i[get post]
  match "/422" => "errors#error_422", via: %i[get post]
  match "/500" => "errors#error_500", via: %i[get post]

  resources :hosts, only: [:index]

  resources :organisations, only: %i[show index] do
    resources :sites, only: %i[new create], controller: :sites
  end

  get "mappings/find_global", to: "mappings#find_global"
  get "hits", to: "hits#universal_summary"
  get "hits/category", to: "hits#universal_category"

  get "leaderboard", to: "leaderboard#index"

  resources :sites, only: %i[edit update show destroy] do
    get :edit_date, to: "site_dates#edit"
    post :update_date, to: "site_dates#update"

    member do
      get :confirm_destroy
    end
    get "mappings/find", as: "mapping_find"
    resources :mappings, only: %i[index edit update] do
      resources :versions, only: [:index]

      collection do
        post "edit_multiple"
        post "update_multiple"

        get "filter"

        resources :bulk_add_batches, only: %i[new create] do
          member do
            get "preview"
            post "import"
          end
        end

        resources :import_batches, only: %i[new create] do
          member do
            get "preview"
            post "import"
          end
        end
      end
    end

    resources :batches, only: [:show]

    resources :hits, only: [:index] do
      collection do
        get "summary"
        get "category"
      end
    end
  end

  namespace :admin do
    resources :whitelisted_hosts, only: %i[index new create]
  end
end
