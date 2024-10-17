Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :restaurants, module: :restaurants do
        resources :menus do
          resources :menu_item_menus, only: [:create, :destroy], param: :menu_item_id
        end

        collection do
          post 'import', to: 'import_files#import_json'
        end
      end

      resources :menu_items
      
    end
  end
end
