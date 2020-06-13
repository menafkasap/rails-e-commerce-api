class User < ApplicationRecord
  has_secure_password

  has_many :orders

  validates :email, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true
end
