class DinosaurAddArmour < ActiveRecord::Migration[6.0]
  def change
    # armour in percent 0 .. 100
    add_column :dinosaurs, :armour, :integer, null: false, default: 0
  end
end
