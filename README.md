# Welcome to Rails E-Commerce API

E-Commerce API is a rails-api where users can add items to their baskets and convert orders by purchasing them.

You can reach [documentation page](https://documenter.getpostman.com/view/5265925/SzzoaFNQ)

#### What you can do

With Rails E-Commerce API you can
- `list/show/create/update/destroy` users
- `list/show/create/update/destroy` products
- `list/show` orders
- `show/add/clear/purchase` basket

#### Models

In this project there are 4 type of models
- User
- Product
- Order(includes basket)
- OrderItem

#### Key points

- `OrderItems` belong to `Orders` and `Products`, `Orders` belong to `Users`.
- `Baskets` are always the last `Order` of `Users` with `order_type: basket` and `Users` will be created with their baskets.
- `Users` can add `OrderItems` to their basket and clear their baskets.
- When purchase process is done `Product`'s inventory will be decrease by `Order`'s amount then new basket will be created.
- Stock error will be given if one of `Products` out of stock while purchasing or adding items to basket.

#### Prerequisites

The setups steps expect following tools installed on the system.

- Github
- Ruby [2.7.1](https://github.com/menafkasap/rails-e-commerce-api/blob/master/.ruby-version#L1)
- Rails [6.0.3](https://github.com/menafkasap/rails-e-commerce-api/blob/master/Gemfile#L7)

#### 1. Check out the repository

```bash
git clone git@github.com:menafkasap/rails-e-commerce-api.git
```

#### 2. Create database.yml file

Copy the sample database.yml file and edit the database configuration as required.

```bash
cp config/database.yml.sample config/database.yml
```

#### 3. Create and setup the database

Run the following commands to create and setup the database.

```ruby
bundle exec rake db:create
bundle exec rake db:create RAILS_ENV=test
```

#### 4. Start the Rails server

You can start the rails server using the command given below.

```ruby
bundle exec rails s
```

And now you can visit the site with the URL http://localhost:3000

#### 5. Run the tests

You can start to run using the command given below.

```ruby
rails test
```
#### 6. Send API requests via Postman

You can send API request via Postman. Download and import json collection file using the link given below.

- [Postman Collection](https://github.com/menafkasap/rails-e-commerce-api/blob/master/config/rails-e-commerce-api.postman_collection.json)
