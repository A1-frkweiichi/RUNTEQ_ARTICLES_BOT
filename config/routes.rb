Rails.application.routes.draw do
  post "/mattermost_bot/open_dialog", to: "mattermost_bots#open_dialog"
  post "/mattermost_bot/submit_dialog", to: "mattermost_bots#submit_dialog"
  get "/up" => "rails/health#show", as: :rails_health_check
end
