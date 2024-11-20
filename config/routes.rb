Rails.application.routes.draw do
  require 'sidekiq'
  require 'sidekiq/web'

  get '/login' => redirect('/users/sign_in')
  get '/signup' => redirect('/users/sign_up')

  devise_for :users
  root to: "static_pages#home"

  # Root namespace
  resources :announcements, only: [:index, :show]
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
  end

  # application status and health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Sidekiq admin dashboard protected by authentication
  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end
  
end
