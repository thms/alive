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

ActiveRecord::Schema.define(version: 2021_09_27_153205) do

  create_table "bosses", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.integer "level", default: 26, null: false
    t.string "rarity", default: "", null: false
    t.integer "health", default: 0, null: false
    t.integer "damage", default: 0, null: false
    t.integer "speed", default: 0, null: false
    t.integer "armor", default: 0, null: false
    t.integer "critical_chance", default: 0, null: false
    t.string "slug"
    t.integer "rounds", default: 1, null: false
    t.string "abilities", default: "", null: false
    t.string "abilities_counter", default: "", null: false
    t.string "resistances", default: "", null: false
    t.string "klass", default: "", null: false
    t.boolean "is_implemented", default: false, null: false
    t.integer "level_cap", default: 0, null: false
    t.integer "boost_cap", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "dinosaurs", force: :cascade do |t|
    t.string "name"
    t.integer "level"
    t.string "rarity"
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
    t.string "resistances", default: "", null: false
    t.integer "attack_boosts", default: 0, null: false
    t.integer "health_boosts", default: 0, null: false
    t.integer "speed_boosts", default: 0, null: false
    t.boolean "is_implemented", default: false, null: false
    t.string "klass", default: "", null: false
    t.integer "health_26", default: 0, null: false
    t.integer "damage_26", default: 0, null: false
  end

  create_table "minions", force: :cascade do |t|
    t.integer "boss_id", default: 0, null: false
    t.string "name", default: "", null: false
    t.integer "level", default: 26, null: false
    t.string "rarity", default: "", null: false
    t.integer "health", default: 0, null: false
    t.integer "damage", default: 0, null: false
    t.integer "speed", default: 0, null: false
    t.integer "armor", default: 0, null: false
    t.integer "critical_chance", default: 0, null: false
    t.string "slug"
    t.string "abilities", default: "", null: false
    t.string "abilities_counter", default: "", null: false
    t.string "resistances", default: "", null: false
    t.string "klass", default: "", null: false
    t.boolean "is_implemented", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
