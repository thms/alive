namespace :dinosaurs do
  desc "Update is_implemented flag based on abilities being implemented"
  task :update_is_implemented => :environment do
    Dinosaur.all.each do |dinosaur|
      dinosaur.reset_attributes!
      all_abilities = [dinosaur.abilities, dinosaur.abilities_counter, dinosaur.abilities_swap_in, dinosaur.abilities_on_escape].flatten
      is_implemented = all_abilities.inject(true) {|is_implemented, ability| is_implemented && ability.is_implemented}
      dinosaur.reload # to get rid of the hyrdation of the abilities
      dinosaur.update_attribute(:is_implemented, is_implemented)
    end
  end
end
