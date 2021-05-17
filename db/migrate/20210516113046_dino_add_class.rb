class DinoAddClass < ActiveRecord::Migration[6.0]
  def change
    add_column :dinosaurs, :klass, :string, null: false, default: ""
  end
end
