require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  post "/mattermost_bot/open_dialog", to: "mattermost_bots#open_dialog"
  post "/mattermost_bot/submit_dialog", to: "mattermost_bots#submit_dialog"
  post "/post_to_x", to: "post_to_x#create"
  get "/up" => "rails/health#show", as: :rails_health_check
end
