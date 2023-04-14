class AddClosedAtToTrades < ActiveRecord::Migration[7.0]
  def change
    add_column :trades, :closed_at, :integer
  end
end
