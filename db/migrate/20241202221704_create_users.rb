class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.decimal  :cash_balance, null: false, precision: 10, scale: 2
      t.timestamps
    end
  end
end
