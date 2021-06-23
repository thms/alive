require 'graphviz'

class TeamMatchesController < ApplicationController

  def index
    name1 = 'Attacker'
    team1 = ['Thoradolosaur', 'Indoraptor', 'Tuoramoloch', 'Monolometrodon']
    name2 = 'Defender'
    team2 = ['Trykosaurus', 'Utarinex', 'Magnapyritor', 'Smilonemys']
    @stats = HashWithIndifferentAccess.new({name1 => 0, name2 => 0, 'draw' => 0})
    @logs = []
    @events = []
    @survivors1 = HashWithIndifferentAccess.new
    @survivors2 = HashWithIndifferentAccess.new
    team1.each {|name| @survivors1[name] = 0}
    team2.each {|name| @survivors2[name] = 0}
    #TQTeamStrategy.load
    TQTeamStrategy.reset
    100.times do
      EventSink.reset
      @t1 = Team.new(name1, team1)
      @t1.strategy = TQTeamStrategy
      @t2 = Team.new(name2, team2)
      #pimp_defense_team
      @t2.strategy = TQTeamStrategy
      @t1.color = '#03a9f4'
      @t2.color = '#03f4a9'
      result = TeamMatch.new(@t1, @t2).execute
      @t1.strategy.learn(result[:outcome_value])
      @t2.strategy.learn(result[:outcome_value])
      @stats[result[:outcome]]+=1
      @logs << result[:log]
      @events << result[:events]
      @t1.health.each {|k,v| @survivors1[k] += 1 if v > 0}
      @t2.health.each {|k,v| @survivors2[k] += 1 if v > 0}
    end
    #TQTeamStrategy.save
    @survivors1.each {|k,v| @survivors1[k] = v * 100 / @logs.size}
    @survivors2.each {|k,v| @survivors2[k] = v * 100 / @logs.size}
    if @logs.size > 10
      @graph = ""
    else
      @graph = generate_graph(@events, name1, name2)
    end
  end

  private
  def pimp_defense_team
    @t2.reset_attributes!
    @t2.dinosaurs.each do |d|
      d.level = 30
      d.health_boosts = 5
      d.attack_boosts = 5
      d.speed_boosts = 5
    end
  end

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
