class DinosaurAddCriticalChance < ActiveRecord::Migration[6.0]
  def change
    # critical chance in percent 0 .. 100
    add_column :dinosaurs, :critical_chance, :integer, null: false, default: 0
  end
end
