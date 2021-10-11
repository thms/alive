class CreateBosses < ActiveRecord::Migration[6.0]
  def change
    create_table :bosses do |t|
      t.string :name, null: false, default: ""
      t.integer :level, null: false, default: 26
      t.string  :rarity, null: false, default: ""
      t.integer :health, null: false, default: 0
      t.integer :damage, null: false, default: 0
      t.integer :speed, null: false, default: 0
      t.integer :armor, null: false, default: 0
      t.integer :critical_chance, null: false, default: 0
      t.string :slug

      t.integer :total_rounds, null: false, default: 1
      t.string :abilities, null: false, default: ""
      t.string :abilities_counter, null: false, default: ""
      t.string :resistances, null: false, default: ""
      t.string :klass, null: false, default: ""
      t.boolean :is_implemented, null: false, default: false
      t.integer :level_cap, null: false, default: 0
      t.integer :boost_cap, null: false, default: 0
      t.timestamps
    end
  end
end
