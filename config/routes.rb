Rails.application.routes.draw do
  resources :testing_grounds do
    collection do
      get  'import'
      post 'import', to: :perform_import
    end

    member do
      get 'technologies'

      get  'export'
      post 'export', to: :perform_export
    end
  end

  resource :session, only: [:new, :create, :destroy]

  resources :load_profiles

  root to: redirect('/welcome')

  get ':id', to: 'pages#show', as: :page
end
