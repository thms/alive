require 'graphviz'

class MatchesController < ApplicationController

  # runs a number of matches to account of randomnes and collects logs from each match, to then graph all paths taken, and the number of times they have been taken
  def index
    #MinMaxStrategy.reset_cache
    name1 = 'Indoraptor'
    name2 = 'Utarinex'
    @stats = HashWithIndifferentAccess.new({name1 => 0, name2 => 0, 'draw' => 0, "#{name1} swapped out" => 0, "#{name2} swapped out" => 0})
    @logs = []
    TQStrategy.load
    #TQStrategy.reset
    MinMaxStrategy.reset
    MinMax2Strategy.reset
    #MinMaxStrategy.load
    NNStrategy.load
    #NNStrategy.reset
    EventSink.reset
    1000.times do
      ForcedStrategy.reset
      @d1 = Dinosaur.find_by_name name1
      @d1.strategy = NNStrategy
      @d2 = Dinosaur.find_by_name name2
      @d2.strategy = TQStrategy
      @d1.color = '#03a9f4'
      @d2.color = '#03f4a9'
      result = Match.new(@d1, @d2).execute
      @d1.strategy.learn(result[:outcome_value])
      @d2.strategy.learn(result[:outcome_value])
      @stats[result[:outcome]]+=1
      @logs << result[:log]
    end
    TQStrategy.save
    NNStrategy.save
    if @logs.size > 10
      @graph = generate_graph([@logs.last], name1, name2)
    else
      @graph = generate_graph(@logs, name1, name2)
    end

  end

  private

  def generate_graph(logs, name1, name2)
    g = Graphviz::Graph.new()
    g.add_node('Start')
    logs.each do |log|
      last_node = g.get_node('Start').first
      # don't need the last node at the moment.
      log.pop
      log.each do |entry|
        title = entry[:health]
        node = g.get_node(title).first || g.add_node(title)
        edge_label = "#{entry[:event]}#{' - crit' if entry[:stats][:is_critical_hit]}#{' - dodged' if entry[:stats][:did_dodge]}"
        edge = last_node.connected?(node) || last_node.connect(node, {label: edge_label})
        edge.attributes[:label] += ", #{edge_label}" unless edge.attributes[:label].include?(edge_label)
        last_node = node
      end
    end
    File.open("tmp/graph.dot", "w") do |output|
      g.dump_graph(output)
    end
    `dot -T svg tmp/graph.dot > tmp/graph.svg`
    graph = File.read('tmp/graph.svg')
    graph
  end

  def generate_graph_orig(logs, name1, name2)
    g = Graphviz::Graph.new()
    d1_wins_graph = g.add_subgraph(name1)
    d2_wins_graph = g.add_subgraph(name2)
    draw_graph = g.add_subgraph('draw')
    d1_start_node = d1_wins_graph.add_node("#{name1} wins")
    d2_start_node = d2_wins_graph.add_node("#{name2} wins")
    draw_start_node = draw_graph.add_node("draw")
    d1_wins_node = d1_wins_graph.add_node("#{name1} - #{@stats[name1]}")
    d2_wins_node = d2_wins_graph.add_node("#{name2} - #{@stats[name2]}")
    draw_node = draw_graph.add_node("draw - #{@stats['draw']}")
    logs.each do |log|
      outcome = log.last[:event]
      if outcome == name1
        last_node = d1_start_node
        log[-1][:event] = "#{name1} - #{@stats[name1]}"
        subgraph = d1_wins_graph
      elsif outcome == name2
        last_node = d2_start_node
        log[-1][:event] = "#{name2} - #{@stats[name2]}"
        subgraph = d2_wins_graph
      else
        last_node = draw_start_node
        log[-1][:event] = "draw - #{@stats['draw']}"
        subgraph = draw_graph
      end
      log.each_with_index do |entry, index|
        title = (entry[:event] == log.last) ? entry : "#{outcome} - #{index} - #{entry[:event]}"
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
    graph = File.read('tmp/graph.svg')
    graph
  end
end
