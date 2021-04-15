require 'graphviz'

class MatchupsController < ApplicationController

  def index
    stats = HashWithIndifferentAccess.new({'d1': 0, 'd2':0})
    logs = []
  100.times do
    d1 = Dinosaur.new(health: 300, damage: 150, speed: 130, level: 20, name: 'd1', abilities: [Strike, Heal, InstantCharge], strategy: RandomStrategy)
    d2 = Dinosaur.new(health: 300, damage: 150, speed: 130, level: 20, name: 'd2', abilities: [Strike, Heal, InstantCharge], strategy: RandomStrategy)
    result = Match.new(d1, d2).execute
    stats[result[:winner]]+=1
    logs << result[:log]
    end
    g = Graphviz::Graph.new()
    d1_wins_graph = g.add_subgraph('d1')
    d2_wins_graph = g.add_subgraph('d2')
    d1_start_node = d1_wins_graph.add_node('d1 start')
    d2_start_node = d2_wins_graph.add_node('d2 start')
    d1_wins_node = d1_wins_graph.add_node("d1 - #{stats['d1']}")
    d2_wins_node = d2_wins_graph.add_node("d2 - #{stats['d2']}")
    logs.each do |log|
      winner = log.last
      if winner == 'd1'
        last_node = d1_start_node
        log[-1] = "d1 - #{stats['d1']}"
        subgraph = d1_wins_graph
      else
        last_node = d2_start_node
        log[-1] = "d2 - #{stats['d2']}"
        subgraph = d2_wins_graph
      end
      log.each_with_index do |entry, index|
        title = (entry == log.last) ? entry : "#{winner} - #{index} - #{entry}"
        node = subgraph.get_node(title).first || subgraph.add_node(title)
        edge = last_node.connected?(node) || last_node.connect(node, {label: 0})
        edge.attributes[:label] += 1
        last_node = node
      end
    end

    File.open("graph.dot", "w") do |output|
      g.dump_graph(output)
    end
    `dot -T svg graph.dot > graph.svg`
    @graph = File.read('graph.svg')
    # the normal ways has massive issues, killing the system (no clue why)
    #@graph = Graphviz::output(g, format: 'svg')
  end
end
