module Restaurants
  class ImportService
    def initialize(restaurant_data)
      @restaurant_data = restaurant_data
    end

    def serialize_and_persist
      return {}
    end
  end
end