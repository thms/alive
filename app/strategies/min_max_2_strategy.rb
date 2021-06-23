require 'logger'

class MinMax2Strategy < Strategy

  FIRST = 0 # indexes for passing around
  LAST  = 1

  @@cache = {}
  @@cache_hits = 0
  @@cache_misses = 0
  @@cache_is_enabled = false
  @@games_played = 0
  @@error_rate = 0.0
  @@root = nil
  @@max_depth = 10
  @@logger = Logger.new(STDOUT)
  @@logger.level = :warn

# returns a single availabe ability from the attacker
  def self.next_move(attacker, defender)
    @@games_played += 1
    if rand < @@error_rate
      move = attacker.availabe_abilities.sample
    elsif attacker.available_abilities.size == 1
      move = attacker.available_abilities.first
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
      EventSink.add "Moves: #{result[:ability_outcomes]}"
      move = attacker.available_abilities.select {|a| a.class.name == result[:ability_outcomes].first.first}.first
    end
    return move
  end

  # Do this differently
  # Returns hash of moves and their values from the attacker's point of view plus the worst outcome
  def self.one_round(current_node, attacker, defender)
    if @@cache_is_enabled
      cache_key = hash_value(current_node, attacker.value)
      if @@cache.key? cache_key
        @@cache_hits += 1
        return @@cache[cache_key]
      end
    end
    # Store the abilities for the attacker and their respective outcome value
    ability_outcomes = {}
    # Safety valve to only look so far into the future
    depth = current_node.data[:depth] + 1
    return {} if depth > @@max_depth
    # create all possible combinations of abilities of the two dinosaurs
    combinations = []
    current_node.data[:dinosaur1].available_abilities.each do |d1_ability|
      current_node.data[:dinosaur2].available_abilities.each do |d2_ability|
        combinations << {d1: deep_clone(current_node.data[:dinosaur1]), d2: deep_clone(current_node.data[:dinosaur2]), a1_class: d1_ability.class, a2_class: d2_ability.class}
      end # inner loop ability combinations
    end # outer loop ability combinations
    combinations.each do |combination|
      # make deep clones of both dinosaurs
      dinosaur1 = combination[:d1]
      dinosaur2 = combination[:d2]
      # use the cloned abilities to get correct cooldown and delay behaviours, and not impact the original behaviours
      ability1 = dinosaur1.abilities.find {|a| a.class == combination[:a1_class]}
      ability2 = dinosaur2.abilities.find {|a| a.class == combination[:a2_class]}
      # order them according to speed, level and priority moves
      dinosaurs, abilities = order_dinosaurs_and_abilities(dinosaur1, dinosaur2, ability1, ability2)

      # first dino attacks
      swapped_out = nil
      if dinosaurs.first.is_stunned
        # no attack if stunned
        first_node = add_or_update_child(current_node, dinosaurs, abilities, FIRST, {}, depth)
        dinosaurs.first.is_stunned = false
      else
        # attack, counterattack, etc if not stunned
        hit_stats = abilities.first.execute(dinosaurs.first, dinosaurs.last)
        swapped_out = dinosaurs.first if abilities.first.is_swap_out
        first_node = add_or_update_child(current_node, dinosaurs, abilities, FIRST, hit_stats, depth)
      end
      if is_final_state?(dinosaurs, swapped_out)
        apply_damage_over_time(dinosaurs)
        update_final_node(first_node, dinosaurs, abilities, attacker, swapped_out, ability_outcomes)
        # skip the other attack, since the state is already final
        next
      end

      # second dino attacks
      swapped_out = nil
      if dinosaurs.last.is_stunned
        # no attack if stunned
        second_node = add_or_update_child(first_node, dinosaurs, abilities, LAST, {}, depth)
        dinosaurs.last.is_stunned = false
      else
        # attack, counterattack, etc if not stunned
        hit_stats = abilities.last.execute(dinosaurs.last, dinosaurs.first)
        swapped_out = dinosaurs.last if abilities.last.is_swap_out
        second_node = add_or_update_child(first_node, dinosaurs, abilities, LAST, hit_stats, depth)
      end
      if is_final_state?(dinosaurs, swapped_out)
        apply_damage_over_time(dinosaurs)
        update_final_node(second_node, dinosaurs, abilities, attacker, swapped_out, ability_outcomes)
        # bubble value up to the first node
        first_node.value = second_node.value
        next
      end
      # at this point both dinos are still alive and we are at the bottom of a round
      # apply damage over time
      apply_damage_over_time(dinosaurs)
      if is_final_state?(dinosaurs, nil)
        update_final_node(second_node, dinosaurs, abilities, attacker, nil, ability_outcomes)
        first_node.value = second_node.value
        next
      else
        result = one_round(second_node, attacker, defender)
        second_node.value = result[:value]
        first_node.value = second_node.value
        update_ability_outcomes(ability_outcomes, attacker, dinosaurs, abilities, result[:value])
      end
    end # combinations.each

    # now we have evaluated all combinations (and done so recursively), so it is time to evaluate.
    # for the choice made in current_node, we need to propagate the best possible outcome of all the combinations in this round as the current_node's value
    if attacker.value == 1.0
      best_outcome = current_node.children.max_by {|node| node.value}.value
    else
      best_outcome = current_node.children.min_by {|node| node.value}.value
    end
    current_node.value = best_outcome
    current_node.children.each do |child|
      @@logger.info "#{child.ability_name} #{child.value}"
      child.children.each do |grand_child|
        @@logger.info "- #{grand_child.ability_name} #{grand_child.value}"
      end
    end

    result = {}
    result[:value] = best_outcome
    @@logger.info best_outcome
    @@logger.info ability_outcomes
    # pick out the best outcomes only
    if attacker.value == 1.0
      ability_outcomes.delete_if {|k,v| v < best_outcome}
    else
      ability_outcomes.delete_if {|k,v| v > best_outcome}
    end
    # If none - which should not happen ever
    @@logger.info ability_outcomes
    key = ability_outcomes.keys.sample
    result[:ability_outcomes] =  {key => ability_outcomes[key]} rescue {}

    # update cache
    if @@cache_is_enabled
      @@cache[cache_key] = result
      @@cache_misses += 1
    end
    # return best ability
    return result
  end

  def self.cache_stats
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

  def self.add_or_update_child(current_node, dinosaurs, abilities, index, hit_stats, depth)
    if dinosaurs[index].is_stunned
      title = "#{dinosaurs[index].name}::stunned"
    else
      title = "#{dinosaurs[index].name}::#{abilities[index].class} #{hit_stats[:is_critical_hit] ? 'crit' : ''}"
    end
    current_node.add_or_update_child(title,
      abilities[index].class,
      {
        dinosaur1: dinosaurs[index],
        dinosaur2: dinosaurs[(index + 1).modulo(1)],
        depth: depth,
        health: health(dinosaurs)
      } )
  end

  # tick both dinosaurs to apply damage over time
  # returns true if one or more are dead, false otherwise
  def self.apply_damage_over_time(dinosaurs)
    dinosaurs.first.tick
    dinosaurs.last.tick
end

  # Returns true if the state is a final state of the game
  def self.is_final_state?(dinosaurs, swapped_out)
    dinosaurs.any? {|d| d.current_health <= 0} || !swapped_out.nil?
  end

  # update final node depending on the current state of the game
  # swapped_out holds the dinosaur who swapped out as a consequence of x-and-run or is nil
  def self.update_final_node(node, dinosaurs, abilities, attacker, swapped_out, ability_outcomes)
    if dinosaurs.first.current_health <= 0 && dinosaurs.last.current_health <= 0
      @@logger.info("Draw")
      node.is_final = true
      node.winner = nil
      node.looser = nil
      node.value = Constants::MATCH[:draw]
      node.data[:health] = health(dinosaurs)
      update_ability_outcomes(ability_outcomes, attacker, dinosaurs, abilities, node.value)
      return true
    elsif dinosaurs.first.current_health <= 0
      node.is_final = true
      node.winner = dinosaurs.last.name
      node.looser = dinosaurs.first.name
      node.value = dinosaurs.last.value
      node.data[:health] = health(dinosaurs)
      update_ability_outcomes(ability_outcomes, attacker, dinosaurs, abilities, node.value)
      return true
    elsif dinosaurs.last.current_health <= 0
      node.is_final = true
      node.winner = dinosaurs.first.name
      node.looser = dinosaurs.last.name
      node.value = dinosaurs.first.value
      node.data[:health] = health(dinosaurs)
      update_ability_outcomes(ability_outcomes, attacker, dinosaurs, abilities, node.value)
      return true
    elsif !swapped_out.nil?
      node.is_final = true
      node.winner = ""
      node.looser = ""
      node.value = swapped_out.value * Constants::MATCH[:swap_out]
      update_ability_outcomes(ability_outcomes, attacker, dinosaurs, abilities, node.value)
      return true
    else
      return false
    end
  end

  def self.update_ability_outcomes(ability_outcomes, attacker, dinosaurs, abilities, value)
    if attacker.name == dinosaurs.first.name
      index = FIRST
    else
      index = LAST
    end
    if attacker.value == 1.0
      ability_outcomes[abilities[index].class.name] = [value, ability_outcomes[abilities[index].class.name]].max rescue value
    else
      ability_outcomes[abilities[index].class.name] = [value, ability_outcomes[abilities[index].class.name]].min rescue value
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

  def self.health(dinosaurs)
    if dinosaurs.first.name < dinosaurs.last.name
      return "#{dinosaurs.first.name}:#{dinosaurs.first.current_health}, #{dinosaurs.last.name}:#{dinosaurs.last.current_health}"
    else
      return "#{dinosaurs.last.name}:#{dinosaurs.last.current_health}, #{dinosaurs.first.name}:#{dinosaurs.first.current_health}"
    end
  end

  def self.deep_clone(object)
    Marshal.load(Marshal.dump(object))
  end

  def self.order_dinosaurs_and_abilities(dinosaur1, dinosaur2, ability1, ability2)
    # order them
    if dinosaur1.current_speed == dinosaur2.current_speed
      dinosaurs = dinosaur1.level > dinosaur2.level ? [ dinosaur1, dinosaur2 ] : [ dinosaur2, dinosaur1 ]
      abilities = dinosaur1.level > dinosaur2.level ? [ ability1, ability2 ] : [ ability2, ability1 ]
      # random shuffling, if speed and level are the same
      if dinosaur1.level == dinosaur2.level
        if rand < 0.5
          dinosaurs = [ dinosaur1, dinosaur2 ]
          abilities = [ ability1, ability2 ]
        else
          dinosaurs = [ dinosaur2, dinosaur1 ]
          abilities = [ ability2, ability1 ]
        end
      end
    else
      dinosaurs = dinosaur1.current_speed > dinosaur2.current_speed ? [ dinosaur1, dinosaur2 ] : [ dinosaur2, dinosaur1 ]
      abilities = dinosaur1.current_speed > dinosaur2.current_speed ? [ ability1, ability2 ] : [ ability2, ability1 ]
    end
    if abilities.last.is_priority && !abilities.first.is_priority
      dinosaurs.reverse!
      abilities.reverse!
    end
    return dinosaurs, abilities
  end


end
