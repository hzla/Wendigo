class ChangeAllocationsInUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :allocations
    add_column :users, :allocations, :integer, array: true
  end
end
