# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_12_02_174816) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "masks", force: :cascade do |t|
    t.string "name", null: false
    t.string "color"
    t.integer "num_per_pack"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "opening_hours", force: :cascade do |t|
    t.time "open", null: false
    t.time "close", null: false
    t.integer "weekday", null: false
    t.bigint "pharmacy_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pharmacy_id"], name: "index_opening_hours_on_pharmacy_id"
  end

  create_table "pharmacies", force: :cascade do |t|
    t.string "name", null: false
    t.decimal "cash_balance", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pharmacy_masks", force: :cascade do |t|
    t.bigint "pharmacy_id", null: false
    t.bigint "mask_id", null: false
    t.decimal "price", precision: 5, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mask_id"], name: "index_pharmacy_masks_on_mask_id"
    t.index ["pharmacy_id"], name: "index_pharmacy_masks_on_pharmacy_id"
  end

  add_foreign_key "opening_hours", "pharmacies"
  add_foreign_key "pharmacy_masks", "masks"
  add_foreign_key "pharmacy_masks", "pharmacies"
end
