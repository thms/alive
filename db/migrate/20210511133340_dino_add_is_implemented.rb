class DinoAddIsImplemented < ActiveRecord::Migration[6.0]
  def change
    add_column :dinosaurs, :is_implemented, :boolean, null: false, default: false
  end
end
