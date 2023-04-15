class CreateUsers < ActiveRecord::Migration[7.0]
  def change

    create_table :users do |t|
      t.string 'address'
      t.string 'copy_list', array: true
    end

    add_index :trades, :trader_id
    add_index :actions, :trader_id
    add_index :actions, :trade_id
  end
end
