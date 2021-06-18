class DinosaurRemoveHealthDamage < ActiveRecord::Migration[6.0]
  def change
    remove_column :dinosaurs, :health
    remove_column :dinosaurs, :damage
  end
end
