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
  ability_classes = (creature['moves'].map {|ability| ability.camelize}).join(',')
  health = creature['health']
  damage = creature['damage']
  speed = creature['speed']
  armor = creature['armor']
  critical_chance = creature['crit']
  Dinosaur.create!({
    slug: slug,
    name: name,
    level: 26,
    rarity: rarity,
    health: health,
    damage: damage,
    armor: armor,
    critical_chance: critical_chance,
    speed: speed,
    dna: 0,
    abilities: ability_classes,
    left_id: nil,
    right_id: nil
  })
end

# Establish links for hybrids 
data['pageProps']['creatures'].each do |creature|
  next if creature['ingredients'].empty?
  puts creature['name']
  left_id  = Dinosaur.find_by_slug(creature['ingredients'].first).id
  right_id = Dinosaur.find_by_slug(creature['ingredients'].last).id
  d = Dinosaur.find_by_slug(creature['name'])
  d.left_id = left_id
  d.right_id = right_id
  d.save
end
