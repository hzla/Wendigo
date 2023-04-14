class AddPnlPercentageToTraders < ActiveRecord::Migration[7.0]
  def change
    add_column :traders, :pnl_percentage, :integer
  end
end
