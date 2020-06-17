class Product < ApplicationRecord
  has_many :order_items, dependent: :destroy

  validates :name, presence: true
  validates :price, presence: true
end
