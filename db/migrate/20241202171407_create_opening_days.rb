class CreateOpeningDays < ActiveRecord::Migration[7.1]
  def change
    create_table :opening_days do |t|
      t.time :open, null: false
      t.time :close, null: false
      t.integer :date_of_week, null: false
      t.references :pharmacy
      t.timestamps
    end
  end
end
