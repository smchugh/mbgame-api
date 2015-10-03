Rails.application.routes.draw do
  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :games
      resources :users do
        collection do
          post 'auth'
          post 'logout'
        end
      end
    end
  end
end
