Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :menus
      resources :menu_items
      resources :restaurants
      resources :menu_item_menus, only: [:index, :create]
      
      scope :menus do
        get "/:id/menu_items", to: "menus#menu_items"
      end

      scope :restaurants do
        get "/:id/menus", to: "restaurants#menus"
      end

      scope :menu_item_menus do
        delete "/destroy", to: "menu_item_menus#destroy"
      end
    end
  end
end
