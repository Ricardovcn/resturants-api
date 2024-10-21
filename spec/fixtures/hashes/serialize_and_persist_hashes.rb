INVALID_KEY_HASH = {
  "restaurants": [
    {
      "name": "Poppo's Cafe",
      "menus": [
        {
          "name": "lunch",
          "menu_items": [
            {
              "name": "Burger",
              "price": 9.00
            },
            {
              "name": "Small Salad",
              "price": 5.00
            }
          ]
        },
        {
          "name": "dinner",
          "menu_items": [
            {
              "name": "Burger",
              "price": 15.00
            },
            {
              "name": "Large Salad",
              "price": 8.00
            }
          ]
        }
      ]
    },
    {
      "name": "Casa del Poppo",
      "menus": [
        {
          "name": "lunch",
          "dishes": [  # This is an invalid key; should be "menu_items"
            {
              "name": "Chicken Wings",
              "price": 9.00
            },
            {
              "name": "Burger",
              "price": 9.00
            },
            {
              "name": "Chicken Wings",
              "price": 9.00
            }
          ]
        },
        {
          "name": "dinner",
          "dishes": [  # This is an invalid key; should be "menu_items"
            {
              "name": "Mega \"Burger\"",
              "price": 22.00
            },
            {
              "name": "Lobster Mac & Cheese",
              "price": 31.00
            }
          ]
        }
      ]
    }
  ]
}

VALID_RESTAURANT_COMPLETE = {
  "restaurants": [
    {
      "name": "Bistro Café",
      "menus": [
        {
          "name": "brunch",
          "menu_items": [
            { "name": "Avocado Toast", "price": 10.00 },
            { "name": "Mimosas", "price": 12.00 }
          ]
        },
        {
          "name": "dinner",
          "menu_items": [
            { "name": "Steak", "price": 25.00 },
            { "name": "Caesar Salad", "price": 10.00 }
          ]
        }
      ],
      "description": "A cozy bistro with outdoor seating.",
      "phone_number": "123-456-7890",
      "email": "contact@bistro.com"
    }
  ]
}

VALID_RESTAURANT_MULTIPLE_MENUS = {
  "restaurants": [
    {
      "name": "Tasty Treats",
      "menus": [
        {
          "name": "breakfast",
          "menu_items": [
            { "name": "Pancakes", "price": 7.00 },
            { "name": "Coffee", "price": 3.00 }
          ]
        },
        {
          "name": "lunch",
          "menu_items": [
            { "name": "Club Sandwich", "price": 9.00 },
            { "name": "Iced Tea", "price": 4.00 }
          ]
        }
      ]
    }
  ]
}

VALID_RESTAURANT_EXTRA_ATTRIBUTES = {
  "restaurants": [
    {
      "name": "Culinary Delights",
      "menus": [
        {
          "name": "dinner",
          "menu_items": [
            { "name": "Seafood Paella", "price": 30.00 },
            { "name": "Chocolate Mousse", "price": 8.00 }
          ]
        }
      ],
      "description": "Fine dining with a unique twist.",
      "phone_number": "987-654-3210",
      "email": "info@culinarydelights.com"
    }
  ]
}

VALID_MENU_MISSING_ITEMS = {
  "restaurants": [
    {
      "name": "Pizza Place",
      "menus": [
        {
          "name": "dinner",
          "menu_items": []  # Empty menu items
        }
      ]
    }
  ]
}

VALID_RESTAURANT_MISSING_MENUS = {
  "restaurants": [
    {
      "name": "Pizza Place",
      "menus": []    # Empty menus
    }
  ]
}

INVALID_RESTAURANT_MISSING_NAME = {
  "restaurants": [
    {
      "menus": [
        {
          "name": "lunch",
          "menu_items": [
            { "name": "Burger", "price": 10.00 }
          ]
        }
      ]
    }
  ]
}

INVALID_MENU_MISSING_NAME = {
  "restaurants": [
    {
      "name": "Pizza Place",
      "menus": [
        {
          "menu_items": [
            { "name": "Burger", "price": 10.00 }
          ]
        }
      ]
    }
  ]
}

INVALID_RESTAURANT_EXTRA_ATTRIBUTES = {
  "restaurants": [
    {
      "name": "Burger Joint",
      "menus": [
        {
          "name": "lunch",
          "menu_items": [
            { "name": "Cheeseburger", "price": 9.00 }
          ]
        }
      ],
      "description": "Fast food joint.",
      "extra_info": "Not allowed attribute"  # This attribute is not permitted
    }
  ]
}

INVALID_MENU_ITEM_INVALID_PRICE = {
  "restaurants": [
    {
      "name": "Sushi Spot",
      "menus": [
        {
          "name": "lunch",
          "menu_items": [
            { "name": "California Roll", "price": "ten" }  # Invalid price type (string instead of numeric)
          ]
        }
      ]
    }
  ]
}