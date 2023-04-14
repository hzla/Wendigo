class AddPnlToTrades < ActiveRecord::Migration[7.0]
  def change
    add_column :trades, :pnl_percentage, :integer
    add_column :trades, :pnl, :float
    add_column :trades, :current_pnl_percentage, :integer
  end
end
