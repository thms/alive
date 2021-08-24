require 'graphviz'
stats = HashWithIndifferentAccess.new({'d1': 0, 'd2':0})
100.times do
d1 = Dinosaur.new(health: 1000, damage: 300, speed: 130, level: 20, name: 'd1', abilities: [DeceleratingImpact], strategy: DefaultStrategy)
d2 = Dinosaur.new(health: 1000, damage: 300, speed: 130, level: 20, name: 'd2', abilities: [CleansingImpact], strategy: DefaultStrategy)
result = Match.new(d1, d2).execute
stats[result[:winner]]+=1
end
stats

stats = HashWithIndifferentAccess.new({'d1': 0, 'd2':0})
100.times do
d1 = Dinosaur.new(health: 1000, damage: 100, speed: 130, level: 20, name: 'd1', abilities: [Strike], strategy: DefaultStrategy)
d2 = Dinosaur.new(health: 1000, damage: 100, speed: 130, level: 20, name: 'd2', abilities: [Strike], strategy: DefaultStrategy)
result = Match.new(d1, d2).execute
stats[result[:winner]]+=1
end
stats


stats = HashWithIndifferentAccess.new({'d1': 0, 'd2':0})
logs = []
100.times do
d1 = Dinosaur.new(health: 1000, damage: 100, speed: 130, level: 20, name: 'd1', abilities: [Strike, Heal, InstantCharge], strategy: RandomStrategy)
d2 = Dinosaur.new(health: 1000, damage: 100, speed: 130, level: 20, name: 'd2', abilities: [Strike, Heal, InstantCharge], strategy: RandomStrategy)
result = Match.new(d1, d2).execute
stats[result[:winner]]+=1
logs << result[:log]
end
stats
g = Graphviz::Graph.new
start_node = g.add_node('start')
d1_wins_node = g.add_node('d1')
d2_wins_node = g.add_node('d2')
last_node = start_node
log = logs.first
log.each do |entry|
  node = g.add_node(entry)
  last_node.connect(node)
  last_node = node
end
graph = Graphviz::output(g, format: 'svg')
