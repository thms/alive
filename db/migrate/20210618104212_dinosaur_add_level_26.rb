class DinosaurAddLevel26 < ActiveRecord::Migration[6.0]
  def change
    add_column :dinosaurs, :health_26, :integer, null: false, default: 0
    add_column :dinosaurs, :damage_26, :integer, null: false, default: 0
  end
end
