Rails.application.routes.draw do
  post "/mattermost_bot/register_qiita", to: "mattermost_bots#register_qiita"
  get "up" => "rails/health#show", as: :rails_health_check
end
