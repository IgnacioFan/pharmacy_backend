class CreateOpeningHours < ActiveRecord::Migration[7.1]
  def change
    create_table :opening_hours do |t|
      t.time :open, null: false
      t.time :close, null: false
      t.integer :weekday, null: false
      t.references :pharmacy, null: false, foreign_key: true
      t.timestamps
    end
  end
end
