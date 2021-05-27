# README
## Goals
Ability to simulate 1:1 battles, and gain statistics
Ability to automatically learn best strategies for 1:1 battles
Ability to simulate 4:4 battles and gain statistics
Ability to automatically learn best strategies for 4:4 battles
Raids?
Ability to calculate cost of evolution for a given dinosaur
Ability to calculate cost to create a given dinosaur
Ability to pick next dinosaur to focus on based on cost, likelihood, as the best next investment of coins, DNA, etc.


## Data Model


## Questions for Evolution
Given current amount of DNA and level, how far can I evolve create and how many coins is that going to cost?

Total cost of dinosaur to date, in DNA and coins
Likelihood to get dinosaur to level x, given average DNA over time (based on total cost for dinosaur to date in DNA and coins)

## Questions for Fighting
Which dinosaur is more likely to win in a given fight?
Which team is more likely to win in a given fight?


Data needed
DNA needed to progress to next level, coins needed to progress to next level
Fusions: dna needed for one fusion for each level of rarity


## TODO
Update simulation strategy to use correct back propagation of rewards and rename to min max strategy
Tabular Q function approach?
Build neural network for the Q-function
cloak attack increases
all abilities
Strategies: learn the best strategy through unsupervised learning (reinforcement learning, Q-Table ...)
Resistances
Implement boost calculations
Refactor model into two parts: generic Dinosaur info, e.g. abilities, health, etc, and player specific , e.g. level, boosts
Implement counter attacks

Implement swap in abilities
Replace graphviz with d3.js for rendering outcome of matchups (dendrogram might be better?)
Matchups: allow picking dinosaurs from the UI, tweak their strength and then run the match
4:4 matches
On escape abilities get triggered by the attempt to swap out from self or other
Swap in abilities activation for 4:4 matches


## DONE
Basic model that shows relationships for Hybrids
Simple render of graph for lineage of Hybrids
CRUD
Cost to get dinosaur to next level in terms of coins and DNA to collect (broken down for hybrids of what the cost is per contributor)
Cost to get dinosaur to level x
Cost to create hybrid, given current ingredients, so we can do the cheapest ones first.
Sort index by column headers (objects)
Priority abilities in Match
Modifiers :: add to a dinosaur
The other columns sorting
shields
armor
Load seeds from dinodex.json
Refactor model to allow swap-in, counter and escape abilities
strategies refactor: use name space, base class, and the ability to look into the match and both Dinosaurs
Use forward looking evaluation as a strategy
distraction
dodge
critical chance

# get the dinodex from here
https://jwatoolbox.com/_next/data/9A_G3Qyrpar9PSLRyQi88/en/dinodex.json

## Boosts

Each level increases health, Damage by 5%
Critical hit: +25% damage



## How To
### Dump DB to seeds
rake db:seed:dump EXCLUDE=

## Strategy and Strongest Dinosaurs
According to Ggamespress.gg version 1.9 their 1:1 simulator, percentage of wins
Geminititan 98%
Indoraptor 2 96%
Ardentismaxima 95%
Magnapyritator 92%
Smilonemys 92%
Procreathomimus 91%
Trykosaurus 89%
Indominus Rex 2 89%
Tenontorex 88%
Ardontosaurus 88%
Bronthoelasmus 87%
Carnotarkus 85%
Erlidominus 84%
Utarinex 84%
Allosinosaurus 83%
Quetzorion 83%
Utasinoraptor 83%
Diorajasaurus 82%
Phorusaura 83%
Carboceratops 83%


## Strategy
Geminitan and Ardentismaxima: use for closing out fights, rather than for opening, since they are hard to kill, but may not have much left afterwards
Indoraptor Gen 2: cautious strikes until opponent slows it down, then mutual fury plus definite rampage or just  rampage.


# Mechanics
## Stat Boosts
sum(boosts) <= dino.level
max tiers per type: 20
attack: max boost = 50%       ==> 2.5% per tier
health: max boost = 50%       ==> 2.5% per tier
speed:  max boost = 40 points ==> 2 points per tier
