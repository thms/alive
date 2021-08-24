# Combination of simulation and min max strategy to bemore efficient and combine caching
require 'logger'


class MinMaxStrategy < Strategy

  @@cache = {}
  @@cache_hits = 0
  @@cache_misses = 0
  @@cache_is_enabled = true
  @@games_played = 0
  @@error_rate = 0.0
  @@max_depth = 5
  @@logger = Logger.new(STDOUT)
  @@logger.level = :warn
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
      # Keep attacker and defender always ordered like that
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

  # returns array of moves with the highest value for the attacker
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
    return {value: 0.0, ability_outcomes: {}} if depth > @@max_depth
    # create all possible combinations of abilities of the two dinosaurs
    current_node.data[:dinosaur1].available_abilities.each do |d1_ability|
      current_node.data[:dinosaur2].available_abilities.each do |d2_ability|
        # make deep clones of both dinosaurs
        dinosaur1 = Utilities.deep_clone(current_node.data[:dinosaur1])
        dinosaur2 = Utilities.deep_clone(current_node.data[:dinosaur2])
        # set the ability to use in this round
        dinosaur1.selected_ability = dinosaur1.abilities.find {|a| a.class == d1_ability.class}
        dinosaur2.selected_ability = dinosaur2.abilities.find {|a| a.class == d2_ability.class}

        # order them
        dinosaurs = Mechanics.order_dinosaurs([dinosaur1, dinosaur2])

        # First attacks
        hit_stats, swapped_out = Mechanics.attack(dinosaurs.first, dinosaurs.last, @@log, @@logger)
        first_node = current_node.add_or_update_child("#{dinosaurs.first.name}::#{dinosaurs.first.selected_ability.class} #{hit_stats[:is_critical_hit] ? 'crit' : ''}",
          dinosaurs.first.selected_ability.class,
          {
            dinosaur1: dinosaur1, # must always be the attacker
            dinosaur2: dinosaur2, # must always be the defender
            depth: depth,
            health: Mechanics.health(dinosaurs)
          }
        )
        # if at least one has died, mark as win / draw and evaluate next combination of moves
        if Mechanics.has_ended?(dinosaurs) || !swapped_out.nil?
          Mechanics.apply_damage_over_time(dinosaurs)
          determine_outcome(first_node, dinosaurs, ability_outcomes, attacker, swapped_out)
          next
        end

        # Second attacks
        hit_stats, swapped_out = Mechanics.attack(dinosaurs.last, dinosaurs.first, @@log, @@logger)
        second_node = first_node.add_or_update_child("#{dinosaurs.last.name}::#{dinosaurs.last.selected_ability.class} #{hit_stats[:is_critical_hit] ? 'crit' : ''}",
          dinosaurs.last.selected_ability.class,
          {
            dinosaur1: dinosaur1,
            dinosaur2: dinosaur2,
            depth: depth,
            health: Mechanics.health(dinosaurs)
          } )
        # if at least one has died, mark as win / draw and evaluate next combination of moves
        if Mechanics.has_ended?(dinosaurs) || !swapped_out.nil?
          Mechanics.apply_damage_over_time(dinosaurs)
          determine_outcome(second_node, dinosaurs, ability_outcomes, attacker, swapped_out)
          # update the parent node's value with this nodes value
          first_node.value = attacker.minimize(second_node.value, first_node.value)
          next
        end

        # if both are still alive, apply damage over time
        Mechanics.apply_damage_over_time(dinosaurs)
        # see if any of them has died. If so mark as final
        next if determine_outcome(second_node, dinosaurs, ability_outcomes, attacker, nil)

        # Both are still alive, advance the clock and explore depth first
        dinosaurs.map(&:tick)

        # since both survived, explore further into the future
        # the move the dinosaur chose above either leads to a win or a loss further down the line
        # so we need to find the worst possible outcome for that selection and bubble that up.
        outcomes = one_round(second_node, dinosaur1, dinosaur2)[:ability_outcomes]
        unless outcomes.empty?
          best_outcome = outcomes.sort_by {|k, v| attacker.value * v}.last.last
          worst_outcome = outcomes.sort_by {|k, v| attacker.value * v}.first.last
          if attacker.name == dinosaurs.first.name
            ability_outcomes[dinosaurs.first.selected_ability.class.name] = worst_outcome
          else
            ability_outcomes[dinosaurs.last.selected_ability.class.name] = worst_outcome
          end
          @@logger.info ability_outcomes
        end
      end # defender abilities
    end # attacker abilities
    @@logger.info ability_outcomes
    # At this point we have {"Strike" => 1.0, "EvasiveStance" => -1.0} so we need to pick the best outcome only
    # TODO: we may want to use a random selection or secondary strategy if there or more than one good moves to choose from
    # or they are all bad - e.g. then go for max damage - although this really only matters if the opponent makes mistakes or in a team match
    result = [ability_outcomes.sort_by {|k,v| attacker.value * v}.last].to_h rescue {}
    result = {value: current_node.value, ability_outcomes: ability_outcomes}

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

  # returns true if one or more are dead, false otherwise
  # updates the final node in the tree with the value of the outcome
  # the update takes the current node value into account: we are looking for the worst outcome
  # from the view of the attacker.
  def self.determine_outcome(node, dinosaurs, ability_outcomes, attacker, swapped_out)
    node.is_final = true
    if dinosaurs.first.current_health == 0 && dinosaurs.last.current_health == 0
      node.winner = nil
      node.looser = nil
      node.value = attacker.minimize(Constants::MATCH[:draw], node.value)
      node.data[:health] = Mechanics.health(dinosaurs)
      update_ability_outcomes(ability_outcomes, attacker, dinosaurs, node.value)
      return true
    elsif dinosaurs.first.current_health == 0
      node.winner = dinosaurs.last.name
      node.looser = dinosaurs.first.name
      # factor in remaining health of self or other
      value = dinosaurs.last.value * (dinosaurs.last.current_health.to_f / dinosaurs.last.health.to_f)
      node.value = attacker.minimize(value, node.value)
      node.data[:health] = Mechanics.health(dinosaurs)
      update_ability_outcomes(ability_outcomes, attacker, dinosaurs, node.value)
      return true
    elsif dinosaurs.last.current_health == 0
      node.winner = dinosaurs.first.name
      node.looser = dinosaurs.last.name
      # factor in remaining health of self or other
      value = dinosaurs.first.value * (dinosaurs.first.current_health.to_f / dinosaurs.first.health.to_f)
      node.value = attacker.minimize(value, node.value)
      node.data[:health] = Mechanics.health(dinosaurs)
      update_ability_outcomes(ability_outcomes, attacker, dinosaurs, node.value)
      return true
    elsif !swapped_out.nil?
      node.winner = ""
      node.looser = ""
      node.data[:health] = Mechanics.health(dinosaurs)
      if swapped_out == dinosaurs.first
        node.value = attacker.minimize(dinosaurs.first.value * Constants::MATCH[:swap_out], node.value)
      else
        node.value = attacker.minimize(dinosaurs.last.value * Constants::MATCH[:swap_out], node.value)
      end
      update_ability_outcomes(ability_outcomes, attacker, dinosaurs, node.value)
    else
      node.is_final = false
      return false
    end
  end

  def self.update_ability_outcomes(ability_outcomes, attacker, dinosaurs, value)
    if attacker.name == dinosaurs.first.name
      ability_outcomes[dinosaurs.first.selected_ability.class.name] = value
    else
      ability_outcomes[dinosaurs.last.selected_ability.class.name] = value
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
