Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      namespace :restaurants do
        resources :restaurants do
          resources :menus
        end
      end

      resources :menu_items
      resources :menu_item_menus, only: [:index, :create]
      scope :menu_item_menus do
        delete "/destroy", to: "menu_item_menus#destroy"
      end
    end
  end
end
