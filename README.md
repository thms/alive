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

## Rails issues
Running
    rails server
will not reliably reload files with spring running. So either do a
    spring stop
after the rails server started or
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

## DOING
4:4 matches

## TODO
MinMax and other strategies: if there is no good move, use highest damage or some other secondary strategy
Tabular Q function approach for 4:4
Build neural network for the Q-function
Cloak attack increases
Remaining abilities
Resistances
Implement swap out abilities
Implement boost calculations
Refactor model into two parts: generic Dinosaur info, e.g. abilities, health, etc, and player specific , e.g. level, boosts

Replace graphviz with d3.js for rendering outcome of matchups (dendrogram might be better?)
Matchups: allow picking dinosaurs from the UI, tweak their strength and then run the match
On escape abilities get triggered by the attempt to swap out from self or other


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
Counters
Tabular Q function approach for 1:1
Implement swap in abilities
Implement X and run abilities
Swap in abilities activation for 4:4 matches

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

## DoT

## Rending attack
damage is x percent of attackers max health bypassing armor and destroying shields
distraction, critical hits and ferocity affect the percentage

## Resistances
### DoT
dot = x
resistance y (y=100%: dot = 0, y=0: dot = x, y=50% dot=0.5*x)

### Critical Reduction
P(d.crit_hit) = x
reduction y (y=100%: x= 0, y=50%: x = 0.5 * x)
P(d.crit_hit) = x * (1-y)
resist reduction z (z=100: x, z=0: x * (1-y), z=50: )
P(d.crit_hit) = x * (1 - y * (1 - z))

### Distraction
damage = x
distraction = y (y=100%: damage = 0; y=50%: damage = 0.5*x; y = 0%: damage = x)
damage = x*(1-y)
resistance z (z=100%: damage = x; z=50%: d = x*(1-0.5*y), z=0: d = x*(1-y))
d = x * (1 - y * (1 -z))

### Rend
damage = x
resistance = y (y=100%: d = 0, y=50% d= 0.5*x)
d = x * (1 - y)

### Speed Decrease
speed = x
reduction = y
s = x * (1 - y)
resistance z
s = x * (1 - y * (1 - z))

### Stun
P(stun) = x
resistance y
P(stun) = x * (1 - y)

### Swap Prevention
P(swap_prevention) = x
resistance y
P(sp) = x * (1 - y)

### Taunt
resistance = x
P(attack any opponent) = x

### Vulnerable
damage = x
vulnerable : true / false
true: damage = 1.25 x
resistance y
damage = (1 + 25% * (1 - y)) * x
