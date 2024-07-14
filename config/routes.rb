require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  post "/register_to_mattermost/open_dialog", to: "register_to_mattermost#open_dialog"
  post "/register_to_mattermost/submit_dialog", to: "register_to_mattermost#submit_dialog"
  post "/post_to_x", to: "post_to_x#create"
  get "/up" => "rails/health#show", as: :rails_health_check
end
