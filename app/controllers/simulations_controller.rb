require 'graphviz'

class SimulationsController < ApplicationController

  def index
    # Example: two monolometrodon, one slightly faster than the other (wthout the resistances yet ...) needs 15 stat boosts to be able to win.
    d1 = Dinosaur.new(health: 4200, damage: 1400, speed: 130, armor: 0, critical_chance: 0, level: 26, name: 'd1', abilities: [Strike], strategy: RandomStrategy)
    d2 = Dinosaur.new(health: 4200, damage: 1400, speed: 130, armor: 0, critical_chance: 0, level: 26, name: 'd2', abilities: [Sidestep, NullifyingRampage], strategy: RandomStrategy)
    d1 = Dinosaur.find_by_name('Velociraptor')
    d2 = Dinosaur.find_by_name('Suchotator')
    d1.reset_attributes!
    d2.reset_attributes!
    if d1.name == d2.name
      d1.name += '-1'
      d2.name += '-2'
    end
    d1.color = '#81d4fa'
    d2.color = '#b2dfdb'
    @simulation = Simulation.new(d1, d2)
    result = @simulation.execute

    full_graph = build_graph(result)
    File.open("tmp/full_graph.dot", "w") do |output|
      full_graph.dump_graph(output)
    end
    `dot -T svg tmp/full_graph.dot > tmp/full_graph.svg`
    @full_graph = File.read('tmp/full_graph.svg')

    # create pruned version of the graph
    @simulation.prune(result)
    pruned_graph = build_graph(result)
    File.open("tmp/pruned_graph.dot", "w") do |output|
      pruned_graph.dump_graph(output)
    end
    `dot -T svg tmp/pruned_graph.dot > tmp/pruned_graph.svg`
    @pruned_graph = File.read('tmp/pruned_graph.svg')

  end

  private
  def build_graph(root)
    graph = Graphviz::Graph.new
    node = graph.add_node(root.name)
    node.attributes[:fontname] = 'verdana, arial, helvetica, sans-serif'
    node.attributes[:fontsize] = 8.0
    graph_add_children(graph, node, root.children)
    graph
  end

  # recursively add children to the graph, connect to the node
  def graph_add_children(graph, parent, children)
    children.each do |child|
      n = graph.add_node(node_title(child))
      n.attributes[:fontname] = 'verdana, arial, helvetica, sans-serif'
      n.attributes[:fontsize] = 8.0
      if child.is_final == true
        n.attributes[:fillcolor] = child.color
        n.attributes[:style] = 'filled'
      end
      parent.connect n
      graph_add_children(graph, n, child.children) unless child.children.empty?

    end
  end

  def node_title(node)
    "#{node.name}\n#{node.data[:health]}\n#{node.id}\n#{node.visits}"
  end
end
