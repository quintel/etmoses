Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: "sessions",
                                    registrations: "users" }

  resources :testing_grounds do
    collection do
      get  'import'
      post 'import', to: :perform_import
      post 'calculate_concurrency'
    end

    member do
      get  'export', 'technology_profile', 'finance'
      post 'data'
      post 'export', to: :perform_export
      post 'save_as'
    end
  end

  resources :price_curves, as: :price_curve
  resources :load_profiles do
    resources :load_profile_component, only: :show
  end
  resources :topologies
  resources :market_models

  root to: redirect('/welcome')

  get ':id', to: 'pages#show', as: :page
end
