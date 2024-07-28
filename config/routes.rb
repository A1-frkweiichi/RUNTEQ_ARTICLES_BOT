require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  # Sidekiq Web UI
  mount Sidekiq::Web => '/sidekiq'

  # Health check
  get '/up', to: 'rails/health#show', as: :rails_health_check

  # Mattermost registration
  namespace :register_to_mattermost do
    post 'open_dialog'
    post 'submit_dialog'
  end

  # X (Twitter) posting
  post '/post_to_x', to: 'post_to_x#create'

  # Gmail OAuth
  get '/oauth2callback', to: 'oauth#callback'
end
