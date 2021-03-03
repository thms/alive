class RenameAbilityClasses < ActiveRecord::Migration[6.0]
  def change
    rename_column :dinosaurs, :ability_classes, :abilities
  end
end
