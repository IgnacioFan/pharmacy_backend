Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      get "pharmacies" => "pharmacy#index"
      get "pharmacies/opening_hours" => "pharmacy#opening_hours"
      get "pharmacies/:pharmacy_id/masks" => "mask#index"
      get "search" => "search#index"
      get "purchases" => "purchase#index"
      get "purchases/report" => "purchase#report"
      post "purchases" => "purchase#create"
    end
  end
end
