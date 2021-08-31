# Runs a simulation of possible path a match can take for a given match
# Looks ahead until all path are exhausted
# needs to treat critical, etc. either via random walks or as branching into two paths
# output is a tree with all possible path and their outcomes
# possible outcomes: one of the two wins, or swaps out, or both die (DoT)

# TODO
# Imlement statistical elements - critical chance, possibiity of a dodge, etc
# Two options: create separte nodes and inject decision
# or: add crit/no-crit, dodge/no-doge to the title of node
require 'logger'

class Simulation

  attr_accessor :dinosaur1
  attr_accessor :dinosaur2

  def initialize(dinosaur1, dinosaur2)
    @dinosaur1 = dinosaur1
    @dinosaur2 = dinosaur2
    @logger = Logger.new(STDOUT)
    @logger.level = :warn
    @round = 1
    @log = [] # ["D1::Strike", "D2::CleansingStrike", ...]
    @root = Node.new('Start')
  end

  def execute
    @root.data = {
      dinosaur1: @dinosaur1,
      dinosaur2: @dinosaur2,
      depth: 0
    }
    one_round(@root)
    return @root
  end

  # calucate the wins and losses for a given node recursively
  # return {name1: {wins: 1, losses: 0}, name2: {wins:2, losses: 5}, draws: 3}
  def calc_wins_and_losses(node, result = nil)
    result = {node.data[:dinosaur1].name => {wins: 0, losses: 0}, node.data[:dinosaur2].name => {wins: 0, losses: 0}, 'draws' => 0} if result.nil?
    # if the node is a leaf, update result and return
    if node.is_final && !node.winner.nil?
      result[node.winner][:wins] += 1
      result[node.looser][:losses] += 1
    elsif node.is_final && node.winner.nil?
      result['draws'] += 1
    else
      node.children.each do |child|
        calc_wins_and_losses(child, result)
      end
    end
    return result
  end


  # prune an entire graph of nodes that are errors by one player
  # TODO: rethink this whole thing to what want out of it
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
  # children have the same dino doing the action
  # then the non-leaves get deleted
  def prune_node(node)
    is_final = false
    dinos_seen = {}
    node.children.each do |child|
      dinos_seen[child.name.split('::').first] = true
      is_final = true if child.is_final
    end
    if is_final && dinos_seen.size == 1
      # prune all non-wins
      node.children.delete_if {|child| !child.is_final }
    end
  end

  private

  # execute one round of the simulation
  # take state of dinosaurs and match from the node's data
  # create / merge  nodes for each combination of possible moves and store the new result back into the tree.
  # only every other level has the dinosaur data after one exchange.
  # if dinosaur dies during the round, mark this node as an end.
  # TODO: add DoT
  # TODO: create separate branches for the different possible outcomes of stun, critical chance, etc, requires a method to get all possible outcomes and to force a specific outcome (otherwise we need to run random battles, and force )
  # Also need to add probability of path taken, once we do that ....
  def one_round(current_node)
    # store all possible starting points for the next round
    next_round_nodes = []

    # create all possible combinations
    depth = current_node.data[:depth] + 1
    # Safety valve to only look so far into the future
    return if depth > 8

    current_node.data[:dinosaur1].available_abilities.each do |d1_ability|
      current_node.data[:dinosaur2].available_abilities.each do |d2_ability|
        # make deep clones of both dinosaurs, including the cooldown, delay and tick counts of abilities and modifiers
        dinosaur1 = Utilities.deep_clone(current_node.data[:dinosaur1])
        dinosaur2 = Utilities.deep_clone(current_node.data[:dinosaur2])
        # set the ability to use in this round
        dinosaur1.selected_ability = dinosaur1.abilities.find {|a| a.class == d1_ability.class}
        dinosaur2.selected_ability = dinosaur2.abilities.find {|a| a.class == d2_ability.class}

        # order them
        dinosaurs = Mechanics.order_dinosaurs([dinosaur1, dinosaur2])
        # First attacks
        hit_stats, swapped_out = Mechanics.attack(dinosaurs.first, dinosaurs.last, @log, @logger)
        node = current_node.add_or_update_child("#{dinosaurs.first.name}::#{dinosaurs.first.selected_ability.class} #{hit_stats[:is_critical_hit] ? 'crit' : ''}",
          dinosaurs.first.selected_ability.class,
          {
            dinosaur1: dinosaurs.first,
            dinosaur2: dinosaurs.last,
            depth: depth,
            health: Mechanics.health(dinosaurs)
          } )
        # call next, and mark the most recent node as a win for the first dinosaur
        # due to counter attacks or or both may be dead, and we need to apply damage over time to find out the final outcome
        if Mechanics.has_ended?(dinosaurs) || !swapped_out.nil?
          Mechanics.apply_damage_over_time(dinosaurs)
          update_final_node(node, dinosaurs)
          next
        end

        # Second attacks
        hit_stats, swapped_out = Mechanics.attack(dinosaurs.last, dinosaurs.first, @log, @logger)
        node = node.add_or_update_child("#{dinosaurs.last.name}::#{dinosaurs.last.selected_ability.class} #{hit_stats[:is_critical_hit] ? 'crit' : ''}",
          dinosaurs.last.selected_ability.class,
          {
          dinosaur1: dinosaurs.first,
          dinosaur2: dinosaurs.last,
          depth: depth,
          health: Mechanics.health(dinosaurs)
        } )
        if Mechanics.has_ended?(dinosaurs) || !swapped_out.nil?
          Mechanics.apply_damage_over_time(dinosaurs)
          update_final_node(node, dinosaurs)
          next
        end

        # Advance the clock
        @round += 1
        # both survived, apply damage over time
        Mechanics.apply_damage_over_time(dinosaurs)
        if Mechanics.has_ended?(dinosaurs)
          update_final_node(node, dinosaurs)
        else
          # if they are still both alive, tick and push for next round
          Mechanics.tick(dinosaurs)
          next_round_nodes << node
        end
      end
    end
    # and recurse through the possible futures
    next_round_nodes.each do |node|
      one_round(node)
    end
  end

  def update_final_node(node, dinosaurs)
    node.is_final = true
    node.data[:health] = Mechanics.health(dinosaurs)
    if dinosaurs.first.current_health <= 0 && dinosaurs.last.current_health <= 0
      node.value = Constants::MATCH[:draw]
      node.winner = nil
      node.looser = nil
      node.color = '#cfd8dc'
    elsif dinosaurs.first.current_health > 0
      node.value = dinosaurs.first.value
      node.winner = dinosaurs.first.name
      node.looser = dinosaurs.last.name
      node.color = dinosaurs.first.color
    else
      node.value = dinosaurs.last.value
      node.winner = dinosaurs.last.name
      node.looser = dinosaurs.first.name
      node.color = dinosaurs.last.color
    end
  end

end
