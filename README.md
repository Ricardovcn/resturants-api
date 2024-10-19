# Restaurant Menu System Challenge

This repository contains a solution to the **Restaurant Menu System Challenge**, built in three progressive levels.
The application is developed using Ruby on Rails.

## Levels Overview

### Level 1: Basics

The code for the first part of the code challenge is place in the main branch.

- **Endpoints**:
  - `GET /api/v1/menus`
  - `POST /api/v1/menus`
  - `GET /api/v1/menus/:id`
  - `PUT /api/v1/menus/:id`
  - `DELETE /api/v1/menus/:id`
  - `GET /api/v1/menu_items`
  - `POST /api/v1/menu_items`
  - `GET /api/v1/menu_items/:id`
  - `PUT /api/v1/menu_items/:id`
  - `DELETE /api/v1/menu_items/:id`
---

### Level 2: Multiple Menus and Restaurants

The modifications for the second part of the code challenge are in a separate branch, with a PR created to make it easier to review.
- **Branch**: [level_2_multiple_menus](https://github.com/Ricardovcn/resturants-api/pull/1)

- **New Endpoints**:
  - `GET /api/v1/restaurants`
  - `POST /api/v1/restaurants`
  - `GET /api/v1/restaurants/:id`
  - `PUT /api/v1/restaurants/:id`
  - `DELETE /api/v1/restaurants/:id`
  - `GET /api/v1/restaurants/:restaurant_id/menus`
  - `POST /api/v1/restaurants/:restaurant_id/menus`
  - `GET /api/v1/restaurants/:restaurant_id/menus/:id`
  - `PUT /api/v1/restaurants/:restaurant_id/menus/:id`
  - `DELETE /api/v1/restaurants/:restaurant_id/menus/:id`
  - `POST /api/v1/restaurants/:restaurant_id/menus/:menu_id/menu_item_menus`
  - `DELETE /api/v1/restaurants/:restaurant_id/menus/:menu_id/menu_item_menus/:menu_item_id`
  - `GET /api/v1/menu_items`
  - `POST /api/v1/menu_items`
  - `GET /api/v1/menu_items/:id`
  - `PUT /api/v1/menu_items/:id`
  - `DELETE /api/v1/menu_items/:id`
---

### Level 3: JSON Import and Logging

The modifications for the third part of the code challenge have been implemented in a separate branch. 
A pull request has been created based on the second part to facilitate the review process.
- **Branch**: [level_3_final](https://github.com/Ricardovcn/resturants-api/pull/2)

- **Changed Endpoints**: The menu items endpoints have been reorganized into a nested structure under restaurants.
  - `GET /api/v1/restaurant/menu_items`
  - `POST /api/v1/restaurants/menu_items`
  - `GET /api/v1/restaurants/menu_items/:id`
  - `PUT /api/v1/restaurants/menu_items/:id`
  - `DELETE /api/v1/restaurants/menu_items/:id`

- **Created Endpoint**:
  - `POST /api/v1/restaurants/import`
---

## Setup and Usage

### Prerequisites
- Ruby version: `2.7.x` or higher
- Rails version: `6.x` or higher
- PostgreSQL for database

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/repo.git
3. Checkout the branch you want to work on:
   - For Level 1: `main`
   - For Level 2: `level_2_bran`
   - For Level 3: `level_3_bran`
   
3. Install dependencies:
   ```bash
   bundle install
   ```

4. Setup the database:
   ```bash
   rails db:create
   rails db:migrate
   ```

### Running the Tests
Execute the test suite with RSpec:
   ```bash
   bundle exec rspec
   ```
### Running the Application
1. Start the server:
  ```bash
  rails s
  ```
2.Use Postman or any HTTP client to test the endpoints listed under each level.

