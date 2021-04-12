class DinosaurAddArmor < ActiveRecord::Migration[6.0]
  def change
    # armor in percent 0 .. 100
    add_column :dinosaurs, :armor, :integer, null: false, default: 0
  end
end
