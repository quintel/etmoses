Rails.application.routes.draw do
  devise_for :users

  resources :testing_grounds, except: :new do
    collection do
      get  'import'
      post 'import', action: :perform_import
      post 'render_template'
    end

    member do
      get  'export', 'technology_profile', 'gas_load', 'heat_load'
      post 'data', 'update_strategies'
      post 'export', action: :perform_export
      patch 'save_as'

      scope :calculation, controller: 'calculation' do
        post 'gas_level_summary'
        post 'heat', 'gas'
      end
    end

    resources :topologies, only: %i(show update)

    resources :market_models, only: :update do
      member { post :replace }
    end

    resources :business_cases, only: [:update, :show] do
      member do
        post 'compare_with', 'data', 'render_summary'
      end
    end

    resources :gas_asset_lists, only: [:update] do
      collection do
        post 'get_types'
      end

      member do
        post 'calculate_net_present_value', 'calculate_cumulative_investment',
             'reload_gas_asset_list', 'load_summary'
      end
    end

    resources :heat_source_lists, only: [:update]
    resources :heat_asset_lists, only: [:update] do
      member do
        post 'reload_heat_asset_list'
      end
    end

    get 'data/price_curve'         => 'data#price_curve',         as: :price_curves
    get 'data/load_curves'         => 'data#load_curves',         as: :load_curves
    get 'data/electricity_storage' => 'data#electricity_storage', as: :electricity_storage
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

  resources :topology_templates do
    member do
      post :download_as_png
      patch :clone
    end
  end

  resources :market_model_templates do
    member { patch :clone }
  end

  root to: redirect('/welcome')

  get ':id', to: 'pages#show', as: :page, constraints: { id: /welcome|how_to/ }
end
