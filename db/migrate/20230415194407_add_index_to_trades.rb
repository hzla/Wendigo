class AddIndexToTrades < ActiveRecord::Migration[7.0]
  def change
    add_index :trades, :timestamp
  end
end
