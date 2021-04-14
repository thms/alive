class DinosaurAddOtherAbilities < ActiveRecord::Migration[6.0]
  def change
    add_column :dinosaurs, :abilities_swap_in, :string, null: false, default: ''
    add_column :dinosaurs, :abilities_counter, :string, null: false, default: ''
    add_column :dinosaurs, :abilities_on_escape, :string, null: false, default: ''
  end
end
