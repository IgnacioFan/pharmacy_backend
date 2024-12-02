class CreatePharmacies < ActiveRecord::Migration[7.1]
  def change
    create_table :pharmacies do |t|
      t.string :name, null: false
      t.decimal  :cash_balance, null: false, precision: 10, scale: 2

      t.timestamps
    end
  end
end
