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
How to apply boosts: probably tier and resulting speed, attack, etc. can do later as refinement


## Data Model


## Questions for Evolution
Given current amount of DNA and level, how far can I evolve create and how many coins is that going to cost?

Total cost of dinosaur to date, in DNA and coins
Likelihood to get dinosaur to level x, given average DNA over time (based on total cost for dinosaur to date in DNA and coins)

## Questions for Fighting
Which dinosaur is more like to win in a given fight?
Which team is more likely to win in a given fight?


Data needed
DNA needed to progress to next level, coins needed to progress to next level
Fusions: dna needed for one fusion for each level of rarity


## TODO
The other columns
## DONE
Basic model that shows relationships for Hybrids
Simple render of graph for lineage of Hybrids
CRUD
Cost to get dinosaur to next level in terms of coins and DNA to collect (broken down for hybrids of what the cost is per contributor)
Cost to get dinosaur to level x
Cost to create hybrid, given current ingredients, so we can do the cheapest ones first.
Sort index by column headers (objects)


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
Brontoelasmus 87%
Carnotarkus 85%
Erlidominus 84%
Utarinex 84%
Allosinosaurus 83%
Quetzorion 83%
Utasinoraptor 83%
Diorajasaurus 82%
Phorusaura 83%
Corboceratops 83%


## Strategy
Geminitan and Ardentismaxima: use for closing out fights, rather than for opening, since they are hard to kill, but may not have much left afterwards
Indoraptor Gen 2: cautious strikes until opponent slows it down, then mutual fury plus definite rampage or just defnite rampage.
