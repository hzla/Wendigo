class AddSizeToTrades < ActiveRecord::Migration[7.0]
  def change
    add_column :trades, :size, :float
    add_column :trades, :collateral, :float
    add_column :trades, :size_delta, :float
    add_column :trades, :collateral_delta, :float
  end
end
