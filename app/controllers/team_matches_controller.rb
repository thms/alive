require 'graphviz'

class TeamMatchesController < ApplicationController

  def index
    name1 = 'A'
    team1 = ['Thoradolosaur', 'Indoraptor', 'Monolometrodon', 'Suchotator']
    name2 = 'D'
    team2 = ['Trykosaurus', 'Utarinex', 'Magnapyritor', 'Smilonemys']
    @stats = HashWithIndifferentAccess.new({name1 => 0, name2 => 0, 'draw' => 0})
    @logs = []
    @events = []
    @survivors1 = HashWithIndifferentAccess.new
    @survivors2 = HashWithIndifferentAccess.new
    team1.each {|name| @survivors1["#{name1}:#{name}"] = 0}
    team2.each {|name| @survivors2["#{name2}:#{name}"] = 0}
    TQTeamStrategy.load
    #TQTeamStrategy.reset
    100.times do
      EventSink.reset
      @t1 = Team.new(name1, team1)
      @t1.strategy = TQTeamStrategy
      @t2 = Team.new(name2, team2)
      @t2.strategy = TQTeamStrategy
      pimp_defense_team
      pimp_offense_team
      @t1.color = '#03a9f4'
      @t2.color = '#03f4a9'
      match = TeamMatch.new(@t1, @t2)
      add_team_name_to_dinosaur_name(@t1)
      add_team_name_to_dinosaur_name(@t2)
      result = match.execute
      @t1.strategy.learn(result[:outcome_value])
      @t2.strategy.learn(result[:outcome_value])
      @stats[result[:outcome]]+=1
      @logs << result[:log]
      @events << result[:events]
      @t1.health.each {|k,v| @survivors1[k] += 1 if v > 0}
      @t2.health.each {|k,v| @survivors2[k] += 1 if v > 0}
    end
    TQTeamStrategy.save
    @survivors1.each {|k,v| @survivors1[k] = v * 100 / @logs.size}
    @survivors2.each {|k,v| @survivors2[k] = v * 100 / @logs.size}
    if @logs.size > 10
      @graph = generate_graph([@events.last], name1, name2)
    else
      @graph = generate_graph(@events, name1, name2)
    end
  end

  private

  def add_team_name_to_dinosaur_name(team)
    team.dinosaurs.each do |dinosaur|
      dinosaur.name = "#{team.name}:#{dinosaur.name}"
    end
  end

  # bring defense team up to level in campagin battle
  def pimp_defense_team
    @t2.reset_attributes!
    @t2.dinosaurs.each do |d|
      d.level = 30
      d.health_boosts = 5
      d.attack_boosts = 5
      d.speed_boosts = 5
    end
  end

  # bring offense team up to expected level for campaign battle
  def pimp_offense_team
    @t1.reset_attributes!
    @t1.dinosaurs.each do |d|
      if d.name.include?('Thoradolosaur')
        d.level = 28
        d.health_boosts = 2
        d.attack_boosts = 4
        d.speed_boosts = 9
      elsif d.name.include?('Monolometrodon')
        d.level = 28
        d.health_boosts = 3
        d.attack_boosts = 16
        d.speed_boosts = 9
      elsif d.name.include?('Indoraptor')
        d.level = 28
        d.health_boosts = 11
        d.attack_boosts = 7
        d.speed_boosts = 8
      elsif d.name.include?('Erlikospyx')
        d.level = 28
        d.health_boosts = 8
        d.attack_boosts = 6
        d.speed_boosts = 9
      elsif d.name.include?('Dracoceratops')
        d.level = 28
        d.health_boosts = 1
        d.attack_boosts = 0
        d.speed_boosts = 0
      elsif d.name.include?('Suchotator')
        d.level = 28
        d.health_boosts = 0
        d.attack_boosts = 0
        d.speed_boosts = 0
      else
        d.level = 28
      end
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
