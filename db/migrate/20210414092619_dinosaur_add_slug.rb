class DinosaurAddSlug < ActiveRecord::Migration[6.0]
  def change
    add_column :dinosaurs, :slug, :string, null: false, default: ''
  end
end
