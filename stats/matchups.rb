stats = HashWithIndifferentAccess.new({'d1 wins': 0, 'd2 wins':0})
1000.times do
d1 = Dinosaur.new(health: 1000, damage: 300, speed: 130, level: 20, name: 'd1', abilities: [DeceleratingStrike])
d2 = Dinosaur.new(health: 1000, damage: 300, speed: 130, level: 20, name: 'd2', abilities: [CleansingStrike])
result = Match.new(d1, d2).execute
stats[result]+=1
end
stats

stats = HashWithIndifferentAccess.new({'d1 wins': 0, 'd2 wins':0})
1000.times do
d1 = Dinosaur.new(health: 1000, damage: 100, speed: 130, level: 20, name: 'd1', abilities: [Strike])
d2 = Dinosaur.new(health: 1000, damage: 100, speed: 130, level: 20, name: 'd2', abilities: [Strike])
result = Match.new(d1, d2).execute
stats[result]+=1
end
stats
