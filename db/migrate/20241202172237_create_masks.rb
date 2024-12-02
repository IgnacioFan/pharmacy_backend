class CreateMasks < ActiveRecord::Migration[7.1]
  def change
    create_table :masks do |t|
      t.string :name, null: false
      t.string :color
      t.integer :num_per_pack
      t.timestamps
    end
  end
end
