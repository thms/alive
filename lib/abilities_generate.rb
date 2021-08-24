# Read all abilities from the dinodex and generate a class file for each that does not yet exit
# Does not fill in any of the data
# Run via rails console
require 'json'
require_relative './lib/generators/ability/ability_generator'

file = File.read(Rails.root.join('db', 'dinodex_2021_08_21.json'))
data =  JSON.parse(file)
abilities = []
data['props']['pageProps']['creatures'].each do |creature|
  abilities << creature['moves']
  abilities << creature['moves_swap_in']
  abilities << creature['moves_counter']
  abilities << creature['moves_on_escape']
end
abilities.flatten!
abilities.uniq!
abilities.count

abilities.each do |ability|
  class_name = ability.camelize
  AbilityGenerator.start [class_name]
end
