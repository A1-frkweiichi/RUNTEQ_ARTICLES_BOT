require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  # Sidekiq Web UI
  mount Sidekiq::Web => '/sidekiq'

  # Mattermost registration
  namespace :register_to_mattermost do
    post 'open_dialog'
    post 'submit_dialog'
  end

  # X (Twitter) posting
  post '/post_to_x', to: 'post_to_x#create'

  # Gmail OAuth
  get '/oauth2callback', to: 'oauth#callback'

  # Redirect root path to GitHub page
  root to: redirect('https://github.com/A1-frkweiichi/RUNTEQ_ARTICLES_BOT')

  # Catch-all route for undefined paths
  match '*path', to: 'application#record_not_found', via: :all

  # Health check
  get '/up', to: 'rails/health#show', as: :rails_health_check
end
