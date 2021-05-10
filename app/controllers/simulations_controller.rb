require 'graphviz'

class SimulationsController < ApplicationController

  def index
    d1 = Dinosaur.new(health: 3000, damage: 1500, speed: 120, level: 20, name: 'd1', abilities: [Strike, InstantCharge], strategy: RandomStrategy)
    d2 = Dinosaur.new(health: 3000, damage: 1500, speed: 130, level: 20, name: 'd2', abilities: [Strike, Heal], strategy: RandomStrategy)
    d1.color = '#03a9f4'
    d2.color = '#03f4a9'
    @simulation = Simulation.new(d1, d2)
    result = @simulation.execute

    g = build_graph(result)
    File.open("tmp/graph.dot", "w") do |output|
      g.dump_graph(output)
    end
    `dot -T svg tmp/graph.dot > tmp/graph.svg`
    @graph = File.read('tmp/graph.svg')
  end

  private
  def build_graph(root)
    graph = Graphviz::Graph.new
    node = graph.add_node(root.name)
    node.attributes[:fontname] = 'verdana, arial, helvetica, sans-serif'
    node.attributes[:fontsize] = 10.0
    graph_add_children(graph, node, root.children)
    graph
  end

  # recursively add children to the graph, connect to the node
  def graph_add_children(graph, parent, children)
    children.each do |child|
      n = graph.add_node(node_title(child))
      n.attributes[:fontname] = 'verdana, arial, helvetica, sans-serif'
      n.attributes[:fontsize] = 10.0
      if child.is_win == true
        n.attributes[:fillcolor] = child.color
        n.attributes[:style] = 'filled'
      end
      parent.connect n
      graph_add_children(graph, n, child.children) unless child.children.empty?

    end
  end

  def node_title(node)
    "#{node.name}\n#{node.data[:health]}\n#{node.id}"
  end
end
