require 'graphviz'

class TeamMatchesController < ApplicationController

  def index
    team1 = ['Thoradolosaur', 'Indoraptor', 'Dracoceratops', 'Suchotator']
    name1 = 'attacker'
    team2 = ['Trykosaurus', 'Utarinex', 'Magnapyritor', 'Smilonemys']
    name2 = 'defender'
    @stats = HashWithIndifferentAccess.new({name1 => 0, name2 => 0, 'draw' => 0})
    @logs = []
    1.times do
      @t1 = Team.new(name1, team1)
      @t1.strategy = DefaultTeamStrategy
      @t2 = Team.new(name2, team2)
      @t2.strategy = DefaultTeamStrategy
      @t1.color = '#03a9f4'
      @t2.color = '#03f4a9'
      result = TeamMatch.new(@t1, @t2).execute
      @stats[result[:outcome]]+=1
      @logs << result[:log]
    end

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
    @graph = File.read('tmp/graph.svg')

  end
end
