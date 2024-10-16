Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :menus
      resources :menu_items
      resources :restaurants
      
      scope :menus do
        get "/:id/menu_items", to: "menus#menu_items"
      end

      scope :restaurants do
        get "/:id/menus", to: "restaurants#menus"
      end
    end
  end
end
