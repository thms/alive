class CreateDinosaurs < ActiveRecord::Migration[6.0]
  def change
    create_table :dinosaurs do |t|
      t.string :name
      t.integer :level
      t.string :rarity
      t.integer :health
      t.integer :damage
      t.integer :speed
      t.integer :dna
      t.integer :left_id
      t.integer :right_id

      t.timestamps
    end
  end
end
