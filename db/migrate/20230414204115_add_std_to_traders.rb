class AddStdToTraders < ActiveRecord::Migration[7.0]
  def change
    add_column :traders, :std, :float
  end
end
