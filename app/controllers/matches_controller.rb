require 'graphviz'

class MatchesController < ApplicationController

  # runs a number of matches to account of randomnes and collects logs from each match, to then graph all paths taken, and the number of times they have been taken
  def index
    name1 = 'Thylacotator'
    name2 = 'Sarcorixis'
    @stats = HashWithIndifferentAccess.new({name1 => 0, name2 => 0, 'draw' => 0, "#{name1} swapped out" => 0, "#{name2} swapped out" => 0})
    @logs = []
    TQStrategy.load
    #TQStrategy.reset
    TQStrategy.disable_learning_mode
    MinMaxStrategy.reset
    MinMax2Strategy.reset
    EventSink.reset
    1.times do
      ForcedStrategy.reset
      @d1 = Dinosaur.find_by_name name1
      @d1.strategy = MinMaxStrategy
      #@d1.strategies = [ForcedStrategy, MinMaxStrategy, TQStrategy]
      @d2 = Dinosaur.find_by_name name2
      @d2.strategy = MinMaxStrategy
      @d2.level = 26
      @d1.level = 26
      @d1.color = '#03a9f4'
      @d2.color = '#03f4a9'
      @start_node_title = start_node_title(@d1.reset_attributes!, @d2.reset_attributes!)
      result = Match.new(@d1, @d2).execute
      @d1.strategy.learn(result[:outcome_value], @d1.value)
      @d2.strategy.learn(result[:outcome_value], @d2.value)
      @stats[result[:outcome]]+=1
      @logs << result[:log]
    end
    TQStrategy.save
    # NNStrategy.save
    if @logs.size > 10
      @graph = generate_graph([@logs.last], name1, name2, @start_node_title)
    else
      @graph = generate_graph(@logs, name1, name2, @start_node_title)
    end

  end

  # Run a set of matches across a pool of dinos to determine who is most likely to win
  # bit of an unusual way to use routing, but this is for trying stuff only.
  def show
    pool = ['Erlikospyx', 'Magnapyritor', 'Testacornibus', 'Mammolania', 'Geminititan', 'Ardentismaxima', 'Erlidominus', 'Monolorhino', 'Scorpius Rex Gen 3', 'Tenontorex', 'Thoradolosaur', 'Indoraptor']
    @all_stats = {}
    TQStrategy.load
    #TQStrategy.reset
    while pool.size > 1 do
      name1 = pool.shift
      @all_stats[name1] = {}
      pool.each do |name2|
        TQStrategy.enable_learning_mode
        1000.times do
          d1 = Dinosaur.find_by_name name1
          d1.strategy = TQStrategy
          d2 = Dinosaur.find_by_name name2
          d2.strategy = TQStrategy
          result = Match.new(d1, d2).execute
          d1.strategy.learn(result[:outcome_value], d1.value)
          d2.strategy.learn(result[:outcome_value], d2.value)
        end
        stats = HashWithIndifferentAccess.new({name1 => 0, name2 => 0, 'draw' => 0, "#{name1} swapped out" => 0, "#{name2} swapped out" => 0})
        TQStrategy.disable_learning_mode
        100.times do
          d1 = Dinosaur.find_by_name name1
          d1.strategy = TQStrategy
          d2 = Dinosaur.find_by_name name2
          d2.strategy = TQStrategy
          result = Match.new(d1, d2).execute
          stats[result[:outcome]]+=1
        end
        @all_stats[name1][name2] = stats[name2]
      end
    end
    TQStrategy.save
  end

  private

  def start_node_title(dinosaur1, dinosaur2)
    Mechanics.health([dinosaur1, dinosaur2])
  end

  def generate_graph(logs, name1, name2, start_node_title)
    g = Graphviz::Graph.new()
    g.add_node(start_node_title)
    logs.each do |log|
      last_node = g.get_node(start_node_title).first
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
