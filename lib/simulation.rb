# Runs a simulation of possible path a match can take for a given match
# Looks ahead until all path are exhausted
# needs to treat critical, etc. either via random walks or as branching into two paths
# output is a tree with all possible path and their outcomes
# possible outcomes: one of the two wins, or swaps out, or both die (DoT)


require 'logger'

class Simulation

  def initialize(dinosaur1, dinosaur2)
    @dinosaur1 = dinosaur1.reset_attributes!
    @dinosaur2 = dinosaur2.reset_attributes!
    @logger = Logger.new(STDOUT)
    @round = 1
    @log = [] # ["D1::Strike", "D2::CleansingStrike", ...]
    @root = Node.new('root')
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

  # execute one round of the simulation
  # take state of dinosaurs and match from the node's data
  # create / merge  nodes for each combination of possible moves and store the new reuslt back into the tree.
  # only every other level has the dinosaur data after one exchange.
  # if dinosaur dies during the round, mark this node as an end.
  # TODO: add DoT
  # TODO: create separate brnaches for the different possible outcomes of stun, critical chance, etc, requires a method to get all possible outcomes and to force a specific outcome (otherwise we need to run random battles, and force )
  # Also need to add probability of path taken, once we do that ....
  def one_round(current_node)
    # store all possible starting points for the next round
    next_round_nodes = []
    @logger.info("top of round")
    @logger.info("#{current_node.data[:dinosaur1].abilities.last.class}: #{current_node.data[:dinosaur1].abilities.last.current_cooldown}")
    @logger.info("#{current_node.data[:dinosaur2].abilities.last.class}: #{current_node.data[:dinosaur2].abilities.last.current_cooldown}")

    # create all possible combinations
    depth = current_node.data[:depth] + 1
    return if depth > 10
    current_node.data[:dinosaur1].available_abilities.each do |d1_ability|
      current_node.data[:dinosaur2].available_abilities.each do |d2_ability|
        # make deep clones of both dinosaurs
        dinosaur1 = deep_clone(current_node.data[:dinosaur1])
        dinosaur2 = deep_clone(current_node.data[:dinosaur2])
        # use the cloned abilities to get correct cooldown and delay behaviours
        a1 = dinosaur1.abilities.find {|a| a.class == d1_ability.class}
        a2 = dinosaur2.abilities.find {|a| a.class == d2_ability.class}
        abilities = [a1, a2]
        # order them
        if dinosaur1.current_speed == dinosaur2.current_speed
          dinosaurs = dinosaur1.level > dinosaur2.level ? [ dinosaur1, dinosaur2 ] : [ dinosaur2, dinosaur1 ]
          abilities = dinosaur1.level > dinosaur2.level ? [ a1, a2 ] : [ a2, a1 ]
          # dinosaurs.shuffle! if dinosaur1.level == dinosaur2.level
        else
          dinosaurs = dinosaur1.current_speed > dinosaur2.current_speed ? [ dinosaur1, dinosaur2 ] : [ dinosaur2, dinosaur1 ]
          abilities = dinosaur1.current_speed > dinosaur2.current_speed ? [a1, a2 ] : [ a2, a1 ]
        end
        if abilities.last.is_priority && !abilities.first.is_priority
          dinosaurs.reverse!
          abilities.reverse!
        end

        # First attacks
        if dinosaurs.first.is_stunned
          @logger.info("#{dinosaurs.first.name} is stunned")
          @log << "#{dinosaurs.first.name}::stunned"
          dinosaurs.first.is_stunned = false
          node = current_node.add_or_update_child( "#{dinosaurs.first.name}::stunned", {
            dinosaur1: dinosaurs.first,
            dinosaur2: dinosaurs.last,
            depth: depth,
            health: health(dinosaurs)
          } )
        else
          @logger.info("#{dinosaurs.first.name}: #{abilities.first.class}")
          @log << "#{dinosaurs.first.name}::#{abilities.first.class}"
          abilities.first.execute(dinosaurs.first, dinosaurs.last)
          node = current_node.add_or_update_child("#{dinosaurs.first.name}::#{abilities.first.class}", {
            dinosaur1: dinosaurs.first,
            dinosaur2: dinosaurs.last,
            depth: depth,
            health: health(dinosaurs)
          } )
        end
        # call next, and mark the most recent node as a win for the first dinosaur
        if dinosaurs.last.current_health <= 0
          node.is_win = true
          next
        end
        # Second attacks
        if dinosaurs.last.is_stunned
          @logger.info("#{dinosaurs.last.name} is stunned")
          @log << "#{dinosaurs.last.name}::stunned"
          dinosaurs.last.is_stunned = false
          node = node.add_or_update_child( "#{dinosaurs.last.name}::stunned", {
            dinosaur1: dinosaurs.first,
            dinosaur2: dinosaurs.last,
            depth: depth,
            health: health(dinosaurs)
    }  )
        else
          @logger.info("#{dinosaurs.last.name}: #{abilities.last.class}")
          @log << "#{dinosaurs.last.name}::#{abilities.last.class}"
          abilities.last.execute(dinosaurs.last, dinosaurs.first)
          node = node.add_or_update_child("#{dinosaurs.last.name}::#{abilities.last.class}", {
            dinosaur1: dinosaurs.first,
            dinosaur2: dinosaurs.last,
            depth: depth,
            health: health(dinosaurs)
          } )
        end
        if dinosaurs.first.current_health <= 0
          node.is_win = true
          next
        end
        # Advance the clock
        @round += 1
        dinosaur1.tick
        dinosaur2.tick
        # since both survived, push last node onto the stack for the next round of simulation
        next_round_nodes << node
      end
    end
    # and recurse through the possible futures
    next_round_nodes.each do |node|
      one_round(node)
    end
  end

  def deep_clone(object)
    Marshal.load(Marshal.dump(object))
  end

  def health(dinosaurs)
    if dinosaurs.first.name < dinosaurs.last.name
      return "#{dinosaurs.first.name}:#{dinosaurs.first.current_health}, #{dinosaurs.last.name}:#{dinosaurs.last.current_health}"
    else
      return "#{dinosaurs.last.name}:#{dinosaurs.last.current_health}, #{dinosaurs.first.name}:#{dinosaurs.first.current_health}"
    end
  end

end
