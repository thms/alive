# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Dinosaur.create([
  {id: 1, name: 'Tarbosaurus', level: 22, rarity: 'common', health: 3702, damage: 1433, speed: 108, dna: 26901, is_hybrid: false, left_id: nil, right_id: nil},
  {id: 2, name: 'Indoraptor', level: 22, rarity: 'unique', health: 3541, damage: 1151, speed: 128, dna: 70, is_hybrid: true, left_id: 4, right_id: 3},
  {id: 3, name: 'Velociraptor', level: 20, rarity: 'common', health: 1231, damage: 1156, speed: 132, dna: 312, is_hybrid: false, left_id: nil, right_id: nil},
  {id: 4, name: 'Indominus Rex', level: 20, rarity: 'legendary', health: 3357, damage: 1119, speed: 111, dna: 43, is_hybrid: true, left_id: 5, right_id: 3},
  {id: 5, name: 'Tyrannosaurus Rex', level: 17, rarity: 'epic', health: 2900, damage: 1224, speed: 102, dna: 202, is_hybrid: false, left_id: nil, right_id: nil},
  {id: 6, name: 'Monolometrodon', level: 19, rarity: 'legendary', health: 2984, damage: 994, speed: 125, dna: 260, is_hybrid: true, left_id: 7, right_id: 8},
  {id: 7, name: 'Dimetrodon Gen 2', level: 16, rarity: 'common', health: 2762, damage: 736, speed: 112, dna: 46611, is_hybrid: false, left_id: nil, right_id: nil},
  {id: 8, name: 'Monolophosaurus Gen 2', level: 15, rarity: 'common', health: 1578, damage: 789, speed: 126, dna: 8383, is_hybrid: false, left_id: nil, right_id: nil},
  {id: 9, name: 'Dilophosauraus Gen 2', level: 21, rarity: 'common', health: 2447, damage: 1739, speed: 127, dna: 30165, is_hybrid: false, left_id: nil, right_id: nil},
  {id: 10, name: 'Allosinosaurus', level: 20, rarity: 'legendary', health: 3357, damage: 1376, speed: 114, dna: 90, is_hybrid: true, left_id: 11, right_id: 12},
  {id: 11, name: 'Allosaurus', level: 21, rarity: 'common', health: 3619, damage: 1371, speed: 104, dna: 20638, is_hybrid: false, left_id: nil, right_id: nil},
  {id: 12, name: 'Sinoceratops', level: 15, rarity: 'epic', health: 1929, damage: 584, speed: 107, dna: 54, is_hybrid: false, left_id: nil, right_id: nil},
  {id: 13, name: 'Monostegotops', level: 19, rarity: 'legendary', health: 2665, damage: 728, speed: 116, dna: 80, is_hybrid: true, left_id: 14, right_id: 15},
  {id: 14, name: 'Stegoceratops', level: 17, rarity: 'epic', health: 2320, damage: 644, speed: 107, dna: 49, is_hybrid: true, left_id: 16, right_id: 17},
  {id: 15, name: 'Monolophosaurus', level: 15, rarity: 'epic', health: 1754, damage: 760, speed: 127, dna: 325, is_hybrid: false, left_id: nil, right_id: nil},
  {id: 16, name: 'Triceratops', level: 11, rarity: 'rare', health: 1875, damage: 480, speed: 111, dna: 870, is_hybrid: false, left_id: nil, right_id: nil},
  {id: 17, name: 'Stegosaurus', level: 12, rarity: 'common', health: 2272, damage: 505, speed: 116, dna: 110, is_hybrid: false, left_id: nil, right_id: nil},
  {id: 18, name: 'Thoradolosaur', level: 22, rarity: 'unique', health: 3578, damage: 1398, speed: 105, dna: 151, is_hybrid: true, left_id: 1, right_id: 10},
  {id: 19, name: 'Dracoceratops', level: 20, rarity: 'legendary', health: 3134, damage: 1119, speed: 115, dna: 300, is_hybrid: true, left_id: 20, right_id: 21},
  {id: 20, name: 'Dracorex Gen 2', level: 15, rarity: 'common', health: 2104, damage: 877, speed: 108, dna: 8112, is_hybrid: false, left_id: nil, right_id: nil},
  {id: 21, name: 'Triceratops Gen 2', level: 15, rarity: 'common', health: 2192, damage: 584, speed: 110, dna: 33793, is_hybrid: false, left_id: nil, right_id: nil},
  {id: 22, name: 'Dracocreatosaurus', level: 0, rarity: 'unique', health: 0, damage: 0, speed: 0, dna: 0, is_hybrid: true, left_id: 19, right_id: 23},
  {id: 23, name: 'Procreatosaurus', level: 16, rarity: 'rare', health: 1841, damage: 798, speed: 126, dna: 700, is_hybrid: false, left_id: nil, right_id: nil},
  {id: 24, name: 'Ardentismaxima', level: 0, rarity: 'unique', health: 0, damage: 0, speed: 0, dna: 0, is_hybrid: true, left_id: 25, right_id: 26},
  {id: 25, name: 'Brachiosaurus', level: 17, rarity: 'epic', health: 3867, damage: 644, speed: 111, dna: 2499, is_hybrid: false, left_id: nil, right_id: nil},
  {id: 26, name: 'Ardontosaurus', level: 0, rarity: 'legendary', health: 0, damage: 0, speed: 0, dna: 120, is_hybrid: true, left_id: 27, right_id: 28},
  {id: 27, name: 'Argentinosaurus', level: 15, rarity: 'rare', health: 3157, damage: 701, speed: 102, dna: 120, is_hybrid: false, left_id: nil, right_id: nil},
  {id: 28, name: 'Secodontosaurus', level: 15, rarity: 'epic', health: 2280, damage: 877, speed: 114, dna: 270, is_hybrid: false, left_id: nil, right_id: nil},
  {id: 29, name: 'Stygidaryx', level: 0, rarity: 'unique', health: 0, damage: 0, speed: 0, dna: 23, is_hybrid: true, left_id: 30, right_id: 31},
  {id: 30, name: 'Darwezopteryx', level: 0, rarity: 'legendary', health: 0, damage: 0, speed: 0, dna: 72, is_hybrid: true, left_id: 32, right_id: 33},
  {id: 31, name: 'Stygimoloch', level: 13, rarity: 'common', health: 1670, damage: 742, speed: 128, dna: 40025, is_hybrid: false, left_id: nil, right_id: nil},
  {id: 32, name: 'Darwinopterus', level: 11, rarity: 'epic', health: 1298, damage: 480, speed: 129, dna: 2735, is_hybrid: false, left_id: nil, right_id: nil},
  {id: 33, name: 'Hatzegopteryx', level: 12, rarity: 'common', health: 2272, damage: 580, speed: 114, dna: 37976, is_hybrid: false, left_id: nil, right_id: nil},
  {id: 34, name: 'Tyrannolophosaur', level: 16, rarity: 'legendary', health: 2587, damage: 1043, speed: 108, dna: 110, is_hybrid: true, left_id: 9, right_id: 35},
  {id: 35, name: 'Tyrannosaurus Rex Gen 2', level: 15, rarity: 'rare', health: 2543, damage: 1052, speed: 104, dna: 906, is_hybrid: false, left_id: nil, right_id: nil},
  {id: 36, name: 'Tenontorex', level: 0, rarity: 'unique', health: 0, damage: 0, speed: 0, dna: 17, is_hybrid: true, left_id: 34, right_id: 37},
  {id: 37, name: 'Tenontosaur', level: 11, rarity: 'rare', health: 2164, damage: 480, speed: 114, dna: 3803, is_hybrid: false, left_id: nil, right_id: nil},
])
