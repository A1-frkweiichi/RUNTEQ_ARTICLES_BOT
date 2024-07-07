require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  post "/mattermost_bot/open_dialog", to: "mattermost_bots#open_dialog"
  post "/mattermost_bot/submit_dialog", to: "mattermost_bots#submit_dialog"
  get "/up" => "rails/health#show", as: :rails_health_check
end
