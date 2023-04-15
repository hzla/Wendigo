class AddPortfolioSizeToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :max_trade_size, :integer
    add_index :traders, :address
  end
end
