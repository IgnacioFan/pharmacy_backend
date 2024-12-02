class CreatePharmacyMasks < ActiveRecord::Migration[7.1]
  def change
    create_table :pharmacy_masks do |t|
      t.references :pharmacy, null: false, foreign_key: true
      t.references :masks, null: false, foreign_key: true
      t.decimal    :price, null: false, precision: 5, scale: 2
      t.timestamps
    end
  end
end
