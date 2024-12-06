Rails.application.routes.draw do
  require 'sidekiq'
  require 'sidekiq/web'

  # Devise routes
  devise_for :users
  get '/login' => redirect('/users/sign_in')
  get '/signup' => redirect('/users/sign_up')

  # Root route
  root to: "static_pages#home"

  # Public namespace
  resources :announcements do # Announcements
    member do
      post :mark_read
    end
    collection do
      post :mark_all_read
    end
  end
  resources :products, only: [:index, :show] # Products
  resources :checkouts, only: [:create] do
    collection do
      get :success
      get :cancel
    end
  end
  # Stripe webhooks
  namespace :webhooks do
    post 'stripe', to: 'stripe#create'
  end

  # Admin Namespace
  namespace :admin do
    get '/', to: 'dashboard#index', as: :dashboard
    resources :users, only: [:index, :edit, :update, :destroy] # User management
    resources :announcements do # Announcement management
      member do
        post :publish
        post :unpublish
      end
    end
    resources :products do # Product Management
      member do
        post :publish
        post :unpublish
        post :archive
        post :unarchive
      end
    end
  end

  # Application status and health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Sidekiq admin dashboard protected by authentication
  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end
end
