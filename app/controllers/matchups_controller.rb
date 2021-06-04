require 'graphviz'

class MatchupsController < ApplicationController

  # runs a number of matches to account of randomnes and collects logs from each match, to then graph all paths taken, and the number of times they have been taken
  def index
    MinMaxStrategy.reset_cache
    name1 = 'Quetzorion'
    name2 = 'Thoradolosaur'
    stats = HashWithIndifferentAccess.new({name1 => 0, name2 => 0})
    logs = []
    10.times do
      # @d1 = Dinosaur.new(health: 350, damage: 150, speed: 132, level: 20, name: name1, klass: 'cunning', abilities: [InstantCharge, Strike], strategy: MinMaxStrategy)
      # @d2 = Dinosaur.new(health: 350, damage: 150, speed: 130, level: 20, name: name2, klass: 'cunning', abilities: [InstantCharge, Strike, HighPounce], strategy: DefaultStrategy)
      @d1 = Dinosaur.find_by_name name1
      @d1.strategy = MinMaxStrategy
      @d2 = Dinosaur.find_by_name name2
      @d2.strategy = MinMaxStrategy
      @d1.color = '#03a9f4'
      @d2.color = '#03f4a9'
      result = Match.new(@d1, @d2).execute
      stats[result[:winner]]+=1
      logs << result[:log]
    end

    g = Graphviz::Graph.new()
    d1_wins_graph = g.add_subgraph(name1)
    d2_wins_graph = g.add_subgraph(name2)
    d1_start_node = d1_wins_graph.add_node("#{name1} wins")
    d2_start_node = d2_wins_graph.add_node("#{name2} wins")
    d1_wins_node = d1_wins_graph.add_node("#{name1} - #{stats[name1]}")
    d2_wins_node = d2_wins_graph.add_node("#{name2} - #{stats[name2]}")
    logs.each do |log|
      winner = log.last
      if winner == name1
        last_node = d1_start_node
        log[-1] = "#{name1} - #{stats[name1]}"
        subgraph = d1_wins_graph
      else
        last_node = d2_start_node
        log[-1] = "#{name2} - #{stats[name2]}"
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

    File.open("tmp/graph.dot", "w") do |output|
      g.dump_graph(output)
    end
    `dot -T svg tmp/graph.dot > tmp/graph.svg`
    @graph = File.read('tmp/graph.svg')
    # the normal ways has massive issues, killing the system (no clue why)
    #@graph = Graphviz::output(g, format: 'svg')
  end
end
