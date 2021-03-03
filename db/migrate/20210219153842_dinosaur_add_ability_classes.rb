class DinosaurAddAbilityClasses < ActiveRecord::Migration[6.0]
  def change
    add_column :dinosaurs, :ability_classes, :string, null: false, default: ''
  end
end
