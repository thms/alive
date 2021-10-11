# Purpose: load all dinosaur data from the dinodex file, so we don't have to populate it maunally
# This has the generic data, non-player specific only
require 'json'

CREATE_DINOSAURS  = false
CREATE_BOSSES     = true
CREATE_MINIONS    = true


# if we have not created the ability class yet, we need to create a fake class for it, for the import to work
def to_constant(name, namespace = nil)
  if namespace.nil?
    name.camelize.constantize rescue Object.const_set(name.camelize, Struct.new(:name))
  else
    "#{namespace}::#{name.camelize}".constantize rescue namespace.constantize.const_set(name.camelize, Struct.new(:name))
  end
end

if CREATE_DINOSAURS
  file = File.read(Rails.root.join('db', 'dinodex_2021_09_29.json'))
  data =  JSON.parse(file)
  # Iterate over dinosaurs and create entry for each
  data['pageProps']['creatures'].each do |creature|
    slug = creature['uuid']
    name = creature['name']
    rarity = creature['rarity']
    abilities = (creature['moves'].map {|ability| to_constant(ability)})
    abilities_counter = (creature['moves_counter'].map {|ability| to_constant(ability)})
    abilities_swap_in = (creature['moves_swap_in'].map {|ability| to_constant(ability)})
    abilities_on_escape = (creature['moves_on_escape'].map {|ability| to_constant(ability)})
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
    d = Dinosaur.find_by_slug(creature['uuid'])
    d.left_id = left_id
    d.right_id = right_id
    d.save
  end
end
if CREATE_BOSSES
  # Create bosses
  # these files have been handcrafted ...
  files = Dir.glob(Rails.root.join('tmp', 'bosses', '*.json'))
  files.each do |name|
    file = File.read(name)
    creature =  JSON.parse(file)['pageProps']['detail']
    slug = creature['uuid'].gsub('_','-')
    name = creature['name']
    rarity = creature['rarity']
    abilities = (creature['moves'].map {|round_abilities| round_abilities.map {|ability| to_constant(ability['uuid'], 'Bosses')}})
    abilities_counter = (creature['moves_counter'].map {|ability| to_constant(ability['uuid'], 'Bosses')})
    resistances = creature['resistance']
    health = creature['health']
    damage = creature['damage']
    speed = creature['speed']
    armor = creature['armor']
    critical_chance = creature['crit']
    klass = creature['class']
    level = creature['level']
    rounds = creature['rounds']
    level_cap = creature['level_cap']
    boost_cap = creature['boost_cap']
    Boss.create!({
      slug: slug,
      name: name,
      level: level,
      level_cap: level_cap,
      boost_cap: boost_cap,
      rounds: rounds,
      rarity: rarity,
      health: health,
      damage: damage,
      armor: armor,
      critical_chance: critical_chance,
      speed: speed,
      abilities: abilities,
      abilities_counter: abilities_counter,
      resistances: resistances,
      klass: klass
    })
  end
end

if CREATE_MINIONS
  # Create minions, from handcrafted files
  files = Dir.glob(Rails.root.join('tmp', 'minions', '*.json'))
  files.each do |name|
    file = File.read(name)
    creature =  JSON.parse(file)['pageProps']['detail']
    slug = creature['uuid'].gsub('_','-')
    name = creature['name']
    rarity = creature['rarity']
    abilities = (creature['moves'].map {|ability| to_constant(ability, 'Minions')})
    abilities_counter = (creature['moves_counter'].map {|ability| to_constant(ability['uuid'], 'Minions')})
    resistances = creature['resistance']
    health = creature['health']
    damage = creature['damage']
    speed = creature['speed']
    armor = creature['armor']
    critical_chance = creature['crit']
    klass = creature['class']
    level = creature['level']
    boss_id = Boss.find_by_slug(creature['boss_uuid'].gsub('_','-')).id
    Minion.create!({
      slug: slug,
      name: name,
      level: level,
      rarity: rarity,
      health: health,
      damage: damage,
      armor: armor,
      critical_chance: critical_chance,
      speed: speed,
      abilities: abilities,
      abilities_counter: abilities_counter,
      resistances: resistances,
      klass: klass,
      boss_id: boss_id
    })
  end
end
