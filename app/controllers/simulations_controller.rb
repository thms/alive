require 'graphviz'

class SimulationsController < ApplicationController

  def index
    d1 = Dinosaur.new(health: 3000, damage: 1500, speed: 120, level: 20, name: 'd1', abilities: [Strike, InstantCharge], strategy: RandomStrategy)
    d2 = Dinosaur.new(health: 3000, damage: 1500, speed: 130, level: 20, name: 'd2', abilities: [Strike, Heal], strategy: RandomStrategy)
    d1 = Dinosaur.find_by_name('Secodontosaurus')
    d2 = Dinosaur.find_by_name('Tyrannosaurus Rex')
    if d1.name == d2.name
      d1.name += '-1'
      d2.name += '-2'
    end
    d1.color = '#03a9f4'
    d2.color = '#03f4a9'
    @simulation = Simulation.new(d1, d2)
    result = @simulation.execute

    full_graph = build_graph(result)
    File.open("tmp/full_graph.dot", "w") do |output|
      full_graph.dump_graph(output)
    end
    `dot -T svg tmp/full_graph.dot > tmp/full_graph.svg`
    @full_graph = File.read('tmp/full_graph.svg')

    # create pruned version of the graph
    prune(result)
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


  def prune(result)
    queue = [result]
    while !queue.empty? do
      node = queue.shift
      prune_node(node)
      node.children.each do |child|
        queue.push(child)
      end
    end
  end

  # prunes children of one node
  # logic: if there is at least one leaf / win in the children and all
  # chidlren have the same dino doing the action
  # then the non-leaves get deleted
  def prune_node(node)
    has_win = false
    dinos_seen = {}
    node.children.each do |child|
      dinos_seen[child.name.split('::').first] = true
      has_win = true if child.is_win
    end
    if has_win && dinos_seen.size == 1
      # prune all non-wins
      node.children.delete_if {|child| !child.is_win }
    end
  end
end
