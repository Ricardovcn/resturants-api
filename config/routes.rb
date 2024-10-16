Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :menus
      resources :menu_items
    end
  end
end
