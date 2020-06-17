class AddStatusToOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :order_type, :string, :default => 'basket'
  end
end
