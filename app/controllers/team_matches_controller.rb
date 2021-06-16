require 'graphviz'

class TeamMatchesController < ApplicationController

  def index
    name1 = 'Attacker'
    #team1 = ['Thoradolosaur', 'Indoraptor', 'Dracoceratops', 'Suchotator']
    team1 = ['Tarbosaurus', 'Velociraptor']
    name2 = 'Defender'
    #team2 = ['Trykosaurus', 'Utarinex', 'Magnapyritor', 'Smilonemys']
    team2 = ['Allosaurus', 'Dilophosaurus Gen 2']
    @stats = HashWithIndifferentAccess.new({name1 => 0, name2 => 0, 'draw' => 0})
    @logs = []
    #TQTeamStrategy.reset
    10.times do
      @t1 = Team.new(name1, team1)
      @t1.strategy = TQTeamStrategy
      @t2 = Team.new(name2, team2)
      @t2.strategy = TQTeamStrategy
      @t1.color = '#03a9f4'
      @t2.color = '#03f4a9'
      result = TeamMatch.new(@t1, @t2).execute
      @t1.strategy.learn(result[:outcome_value])
      @t2.strategy.learn(result[:outcome_value])
      @stats[result[:outcome]]+=1
      @logs << result[:log]
    end

    @graph = generate_graph(@logs, name1, name2)
  end

  private

  def generate_graph(logs, name1, name2)
    g = Graphviz::Graph.new()
    g.add_node('Start')
    logs.each do |log|
      last_node = g.get_node('Start').first
      log.each_with_index do |entry, index|
        # treat last entry differently
        if index == log.size - 1
          title = entry[:event]
          node = g.get_node(title).first || g.add_node(title)
          edge = last_node.connected?(node) || last_node.connect(node, {label: 0})
          edge.attributes[:label] += 1
        else
          title = entry[:health]
          node = g.get_node(title).first || g.add_node(title)
          edge = last_node.connected?(node) || last_node.connect(node, {label: entry[:event]})
          edge.attributes[:label] += ", #{entry[:event]}" unless edge.attributes[:label].include?(entry[:event])
        end
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

  # Original version, quite clumsy
  def generate_graph_orig(logs, name1, name2)
    g = Graphviz::Graph.new()
    t1_wins_graph = g.add_subgraph(name1)
    t2_wins_graph = g.add_subgraph(name2)
    draw_graph = g.add_subgraph('draw')
    t1_start_node = t1_wins_graph.add_node("#{name1} wins")
    t2_start_node = t2_wins_graph.add_node("#{name2} wins")
    draw_start_node = draw_graph.add_node("draw")
    t1_wins_node = t1_wins_graph.add_node("#{name1} - #{@stats[name1]}")
    t2_wins_node = t2_wins_graph.add_node("#{name2} - #{@stats[name2]}")
    draw_node = draw_graph.add_node("draw - #{@stats['draw']}")
    @logs.each do |log|
      outcome = log.last
      if outcome == name1
        last_node = t1_start_node
        log[-1] = "#{name1} - #{@stats[name1]}"
        subgraph = t1_wins_graph
      elsif outcome == name2
        last_node = t2_start_node
        log[-1] = "#{name2} - #{@stats[name2]}"
        subgraph = t2_wins_graph
      else
        last_node = draw_start_node
        log[-1] = "draw - #{@stats['draw']}"
        subgraph = draw_graph
      end
      log.each_with_index do |entry, index|
        title = (entry == log.last) ? entry : "#{outcome} - #{index} - #{entry}"
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
