Rails.application.routes.draw do


  resources :testing_grounds do
    collection do
      get  'import'
      post 'import', to: :perform_import
    end

    member do
      get 'technologies'
    end
  end

  resources :load_profiles

  root to: redirect('/welcome')

  get ':id', to: 'pages#show', as: :page

end
