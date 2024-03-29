module Constants

# Constants for strategies
# swap out needs to be set quite close to a loss, to train TQ to win and only use swap out to avoid loosing in 1:1 battles
MATCH = {win: 1.0, loss: -1.0, draw: 0.0, swap_out: -0.8, max_player: 1.0, min_player: -1.0}
# https://jurassic-world-alive.fandom.com/wiki/Hybrids
KLASSES = [:cunning, :cunning_fierce, :cunning_resilient, :fierce, :fierce_resilient, :resilient, :wild_card]
RESISTANCES = [:critical_reduction, :damage_over_time, :distraction, :rend, :speed_decrease, :stun, :swap_prevention, :taunt, :vulnerable]
RARITIES = [:common, :rare, :epic, :legendary, :unique, :apex]
COLORS = {common: 'grey', rare: 'blue', epic: 'orange', legendary: 'red', unique: 'green', apex: 'black'}
TARGETS = %w(all_opponents attacker escapee fastest highest_dmg highest_hp lowest_hp lowest_hp_teammate most_pos random_opponent self team )
STARTING_LEVELS = {
  common: 1,
  rare: 6,
  epic: 11,
  legendary: 16,
  unique: 21,
  apex: 26
}
MAX_LEVEL = 30

# DNA required to unlock a creature
DNA_TO_UNLOCK = {
  common: 50,
  rare: 100,
  epic: 150,
  legendary: 200,
  unique: 250,
  apex: 300
}
# Cost of fusion depends only on the rarity of the creature that results from the fusion
COINS_TO_FUSE = {
  rare: 20,
  epic: 100,
  legendary: 200,
  unique: 1000,
}
# DNA required for one fusion outer index is starting level and inner is target level
DNA_TO_FUSE = {
  common: {
    rare: 50,
    epic: 200,
    legendary: 500,
    unique: 2000
  },
  rare: {
    epic: 50,
    legendary: 200,
    unique: 500
  },
  epic: {
    legendary: 50,
    unique: 200
  },
  legendary: {
    unique: 50
  }
}
# min levels required by the components to be fused to a dinosaur, does only depend on the target rarity, not the components
MIN_LEVEL_OF_COMPONENTS_TO_FUSE = {
  rare: 5,
  epic: 10,
  legendary: 15,
  unique: 20
}

DNA_PROBABILITY_FUSION = [
  {dna: 10, probability: 500},
  {dna: 20, probability: 300},
  {dna: 30, probability: 245},
  {dna: 40, probability: 100},
  {dna: 50, probability: 70},
  {dna: 60, probability: 10},
  {dna: 70, probability: 7},
  {dna: 80, probability: 4},
  {dna: 90, probability: 2},
  {dna: 100, probability: 1},
]

FUSION_AVERAGE_DNA = DNA_PROBABILITY_FUSION.sum {|entry| entry[:dna]*entry[:probability] } / DNA_PROBABILITY_FUSION.sum {|entry| entry[:probability] }

# coins required to evolve to the next level depend only on the current level of the dinosaur
COINS_TO_EVOLVE = [
  0,
  5,
  10,
  25,
  50,
  100,
  200,
  400,
  600,
  800,
  1000,
  2000,
  4000,
  6000,
  8000,
  10000,
  15000,
  20000,
  30000,
  40000,
  50000,
  60000,
  70000,
  80000,
  90000,
  100000,
  120000,
  150000,
  200000,
  250000
]
# Costs to evolve, array index is the current level of the creature, value is the dna required to evolve to the next level, index 0 is for dinosaurs not yet created
DNA_TO_EVOLVE = {
  common: [
    DNA_TO_UNLOCK[:common],
    100,
    150,
    200,
    250,
    300,
    350,
    400,
    500,
    750,
    1000,
    1250,
    1500,
    2000,
    2500,
    3000,
    3500,
    4000,
    5000,
    7500,
    10000,
    12500,
    15000,
    20000,
    25000,
    30000,
    35000,
    40000,
    50000,
    75000
  ],
  rare: [
    DNA_TO_UNLOCK[:rare],
    0,
    0,
    0,
    0,
    0,
    100,
    150,
    200,
    250,
    300,
    350,
    400,
    500,
    750,
    1000,
    1250,
    1500,
    2000,
    2500,
    3000,
    3500,
    4000,
    5000,
    7500,
    10000,
    12500,
    15000,
    20000,
    25000

  ],
  epic: [
    DNA_TO_UNLOCK[:epic],
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    100,
    150,
    200,
    250,
    300,
    350,
    400,
    500,
    750,
    1000,
    1250,
    1500,
    2000,
    2500,
    3000,
    3500,
    4000,
    5000,
    7500
  ],
  legendary: [
    DNA_TO_UNLOCK[:legendary],
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    100,
    150,
    200,
    250,
    300,
    350,
    400,
    500,
    750,
    1000,
    1250,
    1500,
    2000,
    2500,
  ],
  unique: [
    DNA_TO_UNLOCK[:unique],
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    100,
    150,
    200,
    250,
    300,
    350,
    400,
    500,
    750
  ],
  apex: [
    DNA_TO_UNLOCK[:apex],
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    100,
    150,
    200,
    250
  ]
}
end
