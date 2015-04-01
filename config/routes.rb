Medlink::Application.routes.draw do
  devise_for :users, controllers: { passwords: "passwords" }, skip: [:registrations]
  as :user do
    get 'users/edit' => 'devise/registrations#edit', as: 'edit_user_registration'
    patch 'users/:id' => 'devise/registrations#update', as: 'user_registration'
  end

  resources :countries, only: [:index]

  resources :country_supplies, only: [:index, :create]

  resource :user, only: [:edit, :update]

  resources :users, only: [] do
    resources :responses, only: [:new, :create, :show] do
      %i(archive unarchive).each { |n| post n }
    end
  end

  resources :requests, only: [:new, :create]

  resources :orders, only: [:index] do
    get :manage, on: :collection
  end

  resources :responses, only: [:index]

  resources :reports, only: [:index] do
    [:order_history, :users, :pcmo_response_times].each do |r|
      get r, on: :collection
    end
  end

  namespace :admin do
    resources :users, only: [:new, :create, :edit, :update] do
      %i( upload_csv set_active_country ).each do |action|
        post action, on: :collection
      end
    end
  end

  get '/help' => 'application#help'
  root to: 'application#root'

  post '/medrequest' => 'twilio#receive'
end
