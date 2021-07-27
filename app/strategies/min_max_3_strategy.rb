require 'logger'

class MinMax3Strategy < Strategy
# like mina max 2, but breadth first instead of depth first
  FIRST = 0 # indexes for passing around
  LAST  = 1

  @@cache = {}
  @@cache_hits = 0
  @@cache_misses = 0
  @@cache_is_enabled = false
  @@games_played = 0
  @@error_rate = 0.0
  @@max_depth = 6
  @@logger = Logger.new(STDOUT)
  @@logger.level = :info
  @@log = []
# returns a single availabe ability from the attacker
  def self.next_move(attacker, defender)
    @@games_played += 1
    if rand < @@error_rate
      move = attacker.availabe_abilities.sample
      EventSink.add "#{attacker.name}: #{move.class.name} - random"
    elsif attacker.available_abilities.size == 1
      move = attacker.available_abilities.first
      EventSink.add "#{attacker.name}: #{move.class.name} - only choice"
    else
      # select best possible move
      root = Node.new('Start')
      root.data = {
        dinosaur1: attacker,
        dinosaur2: defender,
        depth: 0
      }

      result = one_round(root, attacker, defender)
      @@logger.info("Moves: #{result[:ability_outcomes]}")
      EventSink.add "#{attacker.name}: #{result[:ability_outcomes]}"
      # pick one of the best moves if there are more than one with the same best value
      if attacker.value == 1.0
        best_outcome = result[:ability_outcomes].values.max
        result[:ability_outcomes].delete_if {|k,v| v < best_outcome}
      else
        best_outcome = result[:ability_outcomes].values.min
        result[:ability_outcomes].delete_if {|k,v| v > best_outcome}
      end
      ability_name = result[:ability_outcomes].keys.sample
      move = attacker.available_abilities.select {|a| a.class.name == ability_name}.first
    end
    return move
  end

  # Returns hash of all possible moves and their values from the attacker's point of view plus the worst outcome
  def self.one_round(current_node, attacker, defender)
    if @@cache_is_enabled
      cache_key = hash_value(current_node, attacker.value)
      if @@cache.key? cache_key
        @@cache_hits += 1
        return @@cache[cache_key]
      end
    end
    # store nodes for the next round
    next_round_nodes = []
    # Store the abilities for the attacker and their respective outcome value
    ability_outcomes = {}
    # Safety valve to only look so far into the future
    depth = current_node.data[:depth] + 1
    return {value: 0.0, ability_outcomes: {}} if depth > @@max_depth
    # create all possible combinations of abilities of the two dinosaurs
    combinations = []
    current_node.data[:dinosaur1].available_abilities.each do |d1_ability|
      current_node.data[:dinosaur2].available_abilities.each do |d2_ability|
        # make deep clones of both dinosaurs
        dinosaur1 = Utilities.deep_clone(current_node.data[:dinosaur1])
        dinosaur2 = Utilities.deep_clone(current_node.data[:dinosaur2])
        # set the ability to use in this round
        dinosaur1.selected_ability = dinosaur1.abilities.find {|a| a.class == d1_ability.class}
        dinosaur2.selected_ability = dinosaur2.abilities.find {|a| a.class == d2_ability.class}
        combinations << {d1: dinosaur1, d2: dinosaur2}
      end # inner loop ability combinations
    end # outer loop ability combinations
    combinations.each do |combination|
      dinosaur1 = combination[:d1]
      dinosaur2 = combination[:d2]
      # order the dinosaurs
      dinosaurs = Mechanics.order_dinosaurs([dinosaur1, dinosaur2])

      # first dino attacks
      hit_stats, swapped_out = Mechanics.attack(dinosaurs.first, dinosaurs.last, @@log, @@logger)
      first_node = current_node.add_or_update_child("#{dinosaurs.first.name}::#{dinosaurs.first.selected_ability.class} #{hit_stats[:is_critical_hit] ? 'crit' : ''}",
        dinosaurs.first.selected_ability.class,
        {
          dinosaur1: dinosaur1,
          dinosaur2: dinosaur2,
          depth: depth,
          health: Mechanics.health(dinosaurs)
        }
      )
      # if at least one has died, mark as win / draw and evaulate next combiation of moves
      if Mechanics.has_ended?(dinosaurs) || !swapped_out.nil?
        Mechanics.apply_damage_over_time(dinosaurs)
        update_final_node(first_node, dinosaurs, ability_outcomes, attacker, swapped_out)
        bubble_value_to_parent(current_node, first_node.value, attacker)
        next
      end

      # second dino attacks
      hit_stats, swapped_out = Mechanics.attack(dinosaurs.last, dinosaurs.first, @@log, @@logger)
      second_node = first_node.add_or_update_child("#{dinosaurs.last.name}::#{dinosaurs.last.selected_ability.class} #{hit_stats[:is_critical_hit] ? 'crit' : ''}",
        dinosaurs.last.selected_ability.class,
        {
          dinosaur1: dinosaur1,
          dinosaur2: dinosaur2,
          depth: depth,
          health: Mechanics.health(dinosaurs)
        }
      )
      # if at least one has died, mark as win / draw and evaulate next combination of moves
      if Mechanics.has_ended?(dinosaurs) || !swapped_out.nil?
        Mechanics.apply_damage_over_time(dinosaurs)
        update_final_node(second_node, dinosaurs, ability_outcomes, attacker, swapped_out)
        bubble_value_to_parent(first_node, second_node.value, attacker)
        next
      end

      # both are still alive, apply damage over time
      Mechanics.apply_damage_over_time(dinosaurs)
      if Mechanics.has_ended?(dinosaurs)
        update_final_node(second_node, dinosaurs, ability_outcomes, attacker, swapped_out)
        bubble_value_to_parent(first_node, second_node.value, attacker)
        next
      else
        # advance the clock and recurse down
        dinosaurs.map(&:tick)
        second_node.data[:dinosaurs] = dinosaurs
        next_round_nodes << second_node
      end
    end # combinations.each

    # if there are nodes to fruther epxlore do it now
    next_round_nodes.each do |node|
      result = one_round(node, attacker, defender)
      node.value = result[:value]
      bubble_value_to_parent(node.parent, node.value, attacker)
      dinosaurs = node.data[:dinosaurs]
      update_ability_outcomes(ability_outcomes, attacker, dinosaurs, result[:value])
    end

    # now we have evaluated all combinations (and done so recursively), so it is time to evaluate.
    # for the choice made in current_node, we need to propagate the best possible outcome of all the combinations in this round as the current_node's value
    if attacker.value == 1.0
      worst_outcome = current_node.children.min_by {|node| node.value || 1.0}.value
    else
      worst_outcome = current_node.children.max_by {|node| node.value || -1.0}.value
    end
    bubble_value_to_parent(current_node, worst_outcome, attacker)
    current_node.children.each do |child|
      @@logger.info "#{child.ability_name} #{child.value}"
      child.children.each do |grand_child|
        @@logger.info "- #{grand_child.ability_name} #{grand_child.value}"
      end
    end

    # When hitting the boundaries of depth search, nodes may have a nil value, reject them here
    result = {}
    @@logger.info "Worst outcome: #{worst_outcome}"
    @@logger.info "Ability outcomes: #{ability_outcomes}"
    result[:value] = worst_outcome
    result[:ability_outcomes] = ability_outcomes.compact

    # update cache
    if @@cache_is_enabled
      @@cache[cache_key] = result
      @@cache_misses += 1
    end
    # return best ability
    return result
  end

  def self.stats
    {size: @@cache.length, hits: @@cache_hits, misses: @@cache_misses}
  end

  def self.cache
    @@cache
  end

  def self.games_played
    @@games_played
  end

  def self.reset
    @@cache = {}
    @@cache_hits = 0
    @@cache_misses = 0
    @@games_played = 0
  end

  def self.save
    state = Marshal.dump({cache: @@cache, cache_hits: @@cache_hits, cache_misses: @@cache_misses, games_played: @@games_played})
    File.open("#{Rails.root}/tmp/min_max_strategy.state", "wb") do |file|
      file.write state
    end
  end

  def self.load
    state = Marshal.load(File.binread("#{Rails.root}/tmp/min_max_strategy.state"))
    @@cache = state[:cache]
    @@cache_hits = state[:cache_hits]
    @@cache_misses = state[:cache_misses]
    @@games_played = state[:games_played]
  end

  private

  # update a node's value during bubbling
  # if the attacker's value is positive: only update if new value is higher than current
  # if the attacker is minimizing only update the if new value is lower than current
  # to make shorter paths to victory more at attractive, reduce value during bubbling
  def self.bubble_value_to_parent(parent, value, attacker)
    return if parent.nil? || value.nil?
    bubble_factor = 1.0
    value = bubble_factor * value
    if attacker.value == 1.0
      parent.value = [bubble_factor * parent.value, value].max rescue value
    else
      parent.value = [bubble_factor * parent.value, value].min rescue value
    end
  end

  # update final node depending on the current state of the game
  # swapped_out holds the dinosaur who swapped out as a consequence of x-and-run or is nil
  def self.update_final_node(node, dinosaurs, ability_outcomes, attacker, swapped_out)
    bubble_factor = 0.95
    node.is_final = true
    if dinosaurs.first.current_health == 0 && dinosaurs.last.current_health == 0
      node.winner = nil
      node.looser = nil
      node.value = Constants::MATCH[:draw] * (bubble_factor ** (node.data[:depth] - 1))
      node.data[:health] = Mechanics.health(dinosaurs)
      update_ability_outcomes(ability_outcomes, attacker, dinosaurs, node.value)
      return true
    elsif dinosaurs.first.current_health == 0
      node.winner = dinosaurs.last.name
      node.looser = dinosaurs.first.name
      node.value = dinosaurs.last.value * (bubble_factor ** (node.data[:depth] - 1))
      node.data[:health] = Mechanics.health(dinosaurs)
      update_ability_outcomes(ability_outcomes, attacker, dinosaurs, node.value)
      return true
    elsif dinosaurs.last.current_health == 0
      node.winner = dinosaurs.first.name
      node.looser = dinosaurs.last.name
      node.value = dinosaurs.first.value * (bubble_factor ** (node.data[:depth] - 1))
      node.data[:health] = Mechanics.health(dinosaurs)
      update_ability_outcomes(ability_outcomes, attacker, dinosaurs, node.value)
      return true
    elsif !swapped_out.nil?
      node.winner = ""
      node.looser = ""
      node.value = swapped_out.value * Constants::MATCH[:swap_out] * (bubble_factor ** (node.data[:depth] - 1))
      update_ability_outcomes(ability_outcomes, attacker, dinosaurs, node.value)
      return true
    else
      node.is_final = false
      return false
    end
  end

  def self.update_ability_outcomes(ability_outcomes, attacker, dinosaurs, value)
    if attacker.name == dinosaurs.first.name
      index = FIRST
    else
      index = LAST
    end
    if attacker.value == 1.0
      ability_outcomes[dinosaurs[index].selected_ability.class.name] = [value, ability_outcomes[dinosaurs[index].selected_ability.class.name]].min rescue value
    else
      ability_outcomes[dinosaurs[index].selected_ability.class.name] = [value, ability_outcomes[dinosaurs[index].selected_ability.class.name]].max rescue value
    end
  end


  # calculate a unique key for the cache that represents the game state
  def self.hash_value(node, attacker_value)
    result = "#{attacker_value} "
    d = node.data[:dinosaur1]
    result << "#{d.name} #{d.current_health} #{d.level} "
    d.abilities.each {|a| result << "#{a.class.name} #{a.current_cooldown} #{a.current_delay} " }
    d.modifiers.each {|m| result << "#{m.class.name} #{m.current_turns} #{m.current_attacks} " }
    result << "- "
    d = node.data[:dinosaur2]
    result << "#{d.name} #{d.current_health} #{d.level} "
    d.abilities.each {|a| result << "#{a.class.name} #{a.current_cooldown} #{a.current_delay} " }
    d.modifiers.each {|m| result << "#{m.class.name} #{m.current_turns} #{m.current_attacks} " }
    result
  end


end
