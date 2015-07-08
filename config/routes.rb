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
      get  'export', 'technology_profile', 'data'
      post 'export', to: :perform_export
      post 'save_as'
    end
  end

  resources :load_profiles
  resources :financial_profiles
  resources :topologies
  resources :market_models

  root to: redirect('/welcome')

  get ':id', to: 'pages#show', as: :page
end
