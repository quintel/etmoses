Rails.application.routes.draw do
  devise_for :users

  resources :testing_grounds, except: :new do
    collection do
      get  'import'
      post 'import', to: :perform_import
      post 'calculate_concurrency', 'fetch_etm_values'
    end

    member do
      get  'export', 'technology_profile'
      post 'data', 'update_strategies'
      post 'export', to: :perform_export
      patch 'save_as'
    end

    resources :business_cases, only: [:update] do
      member do
        post 'compare_with', 'data', 'render_summary'
      end
    end

    resources :merit, only: [] do
      collection do
        get :price_curve, :load_curves
      end
    end
  end

  post :validate_business_case, to: "business_cases#validate"

  resources :price_curves, as: :price_curve, only: %i(new update)
  resources :behavior_profiles, as: :behavior_profile, only: %i(new update)
  resources :profiles

  resources :load_profiles, except: :index do
    resources :load_profile_component, only: :show do
      get :download
    end
  end
  resources :topologies do
    member do
      patch :clone
      post :download_as_png
    end
  end
  resources :market_models do
    member do
      patch :clone
    end
  end

  root to: redirect('/welcome')

  get ':id', to: 'pages#show', as: :page, constraints: { id: /welcome|how_to/ }
end
