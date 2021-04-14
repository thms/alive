# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_04_14_095548) do

  create_table "dinosaurs", force: :cascade do |t|
    t.string "name"
    t.integer "level"
    t.string "rarity"
    t.integer "health"
    t.integer "damage"
    t.integer "speed"
    t.integer "dna"
    t.integer "left_id"
    t.integer "right_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "abilities", default: "", null: false
    t.integer "armor", default: 0, null: false
    t.integer "critical_chance", default: 0, null: false
    t.string "slug", default: "", null: false
    t.string "abilities_swap_in", default: "", null: false
    t.string "abilities_counter", default: "", null: false
    t.string "abilities_on_escape", default: "", null: false
  end

end
