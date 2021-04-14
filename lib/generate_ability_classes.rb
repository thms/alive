
# TODO:
# possibly update the templates

require 'json'
require 'generators/ability/ability_generator'

file = File.read(Rails.root.join('db', './dinodex.json'))
data =  JSON.parse(file)
abilities = []
data['pageProps']['creatures'].each do |creature|
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
