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
      get  'export', 'technology_profile'
      post 'export', to: :perform_export
    end
  end

  resources :load_profiles
  resources :topologies

  root to: redirect('/welcome')

  get ':id', to: 'pages#show', as: :page
end
