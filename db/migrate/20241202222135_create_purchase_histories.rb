class CreatePurchaseHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :purchase_histories do |t|
      t.references :user, null: false, foreign_key: true
      t.references :pharmacy_mask, null: false, foreign_key: true
      t.decimal    :transaction_amount, null: false, precision: 5, scale: 2
      t.datetime   :transaction_date, null: false
      t.timestamps
    end
  end
end
