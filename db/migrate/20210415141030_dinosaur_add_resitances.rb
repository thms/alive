class DinosaurAddResitances < ActiveRecord::Migration[6.0]
  def change
    add_column :dinosaurs, :resistances, :string, null: false, default: ''
  end
end
