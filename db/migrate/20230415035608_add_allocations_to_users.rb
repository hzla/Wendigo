class AddAllocationsToUsers < ActiveRecord::Migration[7.0]
  def change
     add_column :users, :allocations, :string, array: true
  end
end
