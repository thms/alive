class CreateMinions < ActiveRecord::Migration[6.0]
  def change
    create_table :minions do |t|
      t.integer :boss_id, null: false, default: 0
      t.string :name, null: false, default: ""
      t.integer :level, null: false, default: 26
      t.string  :rarity, null: false, default: ""
      t.integer :health, null: false, default: 0
      t.integer :damage, null: false, default: 0
      t.integer :speed, null: false, default: 0
      t.integer :armor, null: false, default: 0
      t.integer :critical_chance, null: false, default: 0
      t.string :slug

      t.string :abilities, null: false, default: ""
      t.string :abilities_counter, null: false, default: ""
      t.string :resistances, null: false, default: ""
      t.string :klass, null: false, default: ""
      t.boolean :is_implemented, null: false, default: false
      t.timestamps
    end
  end
end
