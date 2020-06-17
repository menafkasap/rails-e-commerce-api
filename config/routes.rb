Rails.application.routes.draw do
  resources :users do
    resources :orders, only: [:index, :show]
    resources :orders, only: [:basket, :add, :purchase, :clear], path: '/basket' do
      # basket is an order with type of basket
      collection do
        get '/', to: 'orders#basket'
        post '/add', to: 'orders#add'
        post '/purchase', to: 'orders#purchase'
        delete '/clear', to: 'orders#clear'
      end
    end
  end
  resources :products
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
