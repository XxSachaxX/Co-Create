Rails.application.routes.draw do
  root "projects#index"
  get "/" => "sessions#new", as: :home
  resource :session
  resources :users, only: [ :new, :create ] do
    resources :projects, only: [ :new, :create, :edit, :update, :destroy ]
    get "projects(/:user_id)", to: "projects#user_projects", as: :user_projects
  end
  resources :projects, except: [ :new, :create, :edit, :update, :destroy ] do
    resources :messages, only: [ :index, :create ]
    member do
      post :join, to: "projects#join"
      post :leave, to: "projects#leave"
    end
  end
  resources :project_memberships, only: [] do
    member do
      post :revoke, to: "project_memberships#revoke"
    end
  end
  resources :project_membership_requests, only: [ :create, :new ] do
    member do
      post :accept, to: "project_membership_requests#accept"
      post :reject, to: "project_membership_requests#reject"
    end
  end
  resources :passwords, param: :token

  # Static pages
  get "terms", to: "static_pages#terms", as: :terms
  get "privacy", to: "static_pages#privacy", as: :privacy

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
