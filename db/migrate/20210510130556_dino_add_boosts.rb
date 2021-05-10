class DinoAddBoosts < ActiveRecord::Migration[6.0]
  def change
    add_column :dinosaurs, :attack_boosts, :integer, null: false, default: 0
    add_column :dinosaurs, :health_boosts, :integer, null: false, default: 0
    add_column :dinosaurs, :speed_boosts, :integer, null: false, default: 0
  end
end
