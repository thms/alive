# Purpose: load all dinosaur data from the dinodex file, so we don't have to populate it maunally
# This has the generic data, non-player specific only
require 'json'

file = File.read(Rails.root.join('db', './dinodex.json'))
data =  JSON.parse(file)

# Iterate over dinosaurs and create entry for each
data['pageProps']['creatures'].each do |creature|
  slug = creature['name']
  name = (creature['name'].split('_').map {|word| word.camelize}).join(' ')
  rarity = creature['rarity']
  abilities = (creature['moves'].map {|ability| ability.camelize.constantize})
  abilities_counter = (creature['moves_counter'].map {|ability| ability.camelize.constantize})
  abilities_swap_in = (creature['moves_swap_in'].map {|ability| ability.camelize.constantize})
  abilities_on_escape = (creature['moves_on_escape'].map {|ability| ability.camelize.constantize})
  resistances = creature['resistance']
  health = creature['health']
  damage = creature['damage']
  speed = creature['speed']
  armor = creature['armor']
  critical_chance = creature['crit']
  klass = creature['class']
  Dinosaur.create!({
    slug: slug,
    name: name,
    level: 26,
    rarity: rarity,
    health_26: health,
    damage_26: damage,
    armor: armor,
    critical_chance: critical_chance,
    speed: speed,
    dna: 0,
    abilities: abilities,
    abilities_counter: abilities_counter,
    abilities_swap_in: abilities_swap_in,
    abilities_on_escape: abilities_on_escape,
    resistances: resistances,
    klass: klass,
    left_id: nil,
    right_id: nil
  })
end

# Establish links for hybrids
data['pageProps']['creatures'].each do |creature|
  next if creature['ingredients'].empty?
  left_id  = Dinosaur.find_by_slug(creature['ingredients'].first).id
  right_id = Dinosaur.find_by_slug(creature['ingredients'].last).id
  d = Dinosaur.find_by_slug(creature['name'])
  d.left_id = left_id
  d.right_id = right_id
  d.save
end
