# Combination of simulation and min max strategy to bemore efficient and combine caching
require 'logger'


class MinMaxStrategy < Strategy

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

      moves = one_round(root, attacker, defender)
      @@logger.info("Moves: #{moves}")
      EventSink.add "Moves: #{moves}"
      move = attacker.available_abilities.select {|a| a.class.name == moves.first.first}.first
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
    return {} if depth > @@max_depth
    # create all possible combinations of abilities of the two dinosaurs
    current_node.data[:dinosaur1].available_abilities.each do |d1_ability|
      current_node.data[:dinosaur2].available_abilities.each do |d2_ability|
        # make deep clones of both dinosaurs
        dinosaur1 = deep_clone(current_node.data[:dinosaur1])
        dinosaur2 = deep_clone(current_node.data[:dinosaur2])
        # use the cloned abilities to get correct cooldown and delay behaviours from the original ones, rather than the clones
        a1 = dinosaur1.abilities.find {|a| a.class == d1_ability.class}
        a2 = dinosaur2.abilities.find {|a| a.class == d2_ability.class}
        abilities = [a1, a2]
        # order them
        if dinosaur1.current_speed == dinosaur2.current_speed
          dinosaurs = dinosaur1.level > dinosaur2.level ? [ dinosaur1, dinosaur2 ] : [ dinosaur2, dinosaur1 ]
          abilities = dinosaur1.level > dinosaur2.level ? [ a1, a2 ] : [ a2, a1 ]
          # random shuffling, if speed and level are the same
          if dinosaur1.level == dinosaur2.level
            if rand < 0.5
              dinosaurs = [ dinosaur1, dinosaur2 ]
              abilities = [ a1, a2 ]
            else
              dinosaurs = [ dinosaur2, dinosaur1 ]
              abilities = [ a2, a1 ]
            end
          end
        else
          dinosaurs = dinosaur1.current_speed > dinosaur2.current_speed ? [ dinosaur1, dinosaur2 ] : [ dinosaur2, dinosaur1 ]
          abilities = dinosaur1.current_speed > dinosaur2.current_speed ? [a1, a2 ] : [ a2, a1 ]
        end
        if abilities.last.is_priority && !abilities.first.is_priority
          dinosaurs.reverse!
          abilities.reverse!
        end
        swapped_out = ""
        # First attacks
        if dinosaurs.first.is_stunned
          @@logger.info("#{dinosaurs.first.name} is stunned")
          dinosaurs.first.is_stunned = false
          node = current_node.add_or_update_child( "#{dinosaurs.first.name}::stunned", '', {
            dinosaur1: dinosaurs.first,
            dinosaur2: dinosaurs.last,
            depth: depth,
            health: health(dinosaurs)
          } )
        else
          @@logger.info("#{dinosaurs.first.name}: #{abilities.first.class}")
          hit_stats = abilities.first.execute(dinosaurs.first, dinosaurs.last)
          swapped_out = dinosaurs.first.name if abilities.first.is_swap_out
          node = current_node.add_or_update_child("#{dinosaurs.first.name}::#{abilities.first.class} #{hit_stats[:is_critical_hit] ? 'crit' : ''}",
            abilities.first.class,
            {
              dinosaur1: dinosaurs.first,
              dinosaur2: dinosaurs.last,
              depth: depth,
              health: health(dinosaurs)
            } )
        end
        # call next, and mark the most recent node as a win for the first dinosaur
        if dinosaurs.last.current_health <= 0
          unless apply_damage_over_time(node, dinosaurs, ability_outcomes, abilities, attacker)
            node.is_final = true
            node.winner = dinosaurs.first.name
            node.looser = dinosaurs.last.name
            node.value = dinosaurs.first.value
            @@logger.info("1: Winner: #{node.winner}, looser: #{node.looser}, attacker: #{attacker.name}, #{node.winner == attacker.name}")
            if dinosaurs.first.name == attacker.name
              # store this as a winning node for the attacker (who may have value -1.0)
              ability_outcomes[abilities.first.class.name] = node.value
            else
              # store the selection of the attacker as a loss
              ability_outcomes[abilities.last.class.name] = node.value
            end
          end
          @@logger.info ability_outcomes
          next
        elsif !swapped_out.empty?
          node.is_final = true
          node.winner = ""
          node.looser = ""
          node.value = dinosaurs.first.value * Constants::MATCH[:swap_out]
          ability_outcomes[abilities.first.class.name] = node.value
          next
        end
        # Second attacks
        if dinosaurs.last.is_stunned
          @@logger.info("#{dinosaurs.last.name} is stunned")
          dinosaurs.last.is_stunned = false
          node = node.add_or_update_child( "#{dinosaurs.last.name}::stunned", '', {
            dinosaur1: dinosaurs.first,
            dinosaur2: dinosaurs.last,
            depth: depth,
            health: health(dinosaurs)
          })
        else
          @@logger.info("#{dinosaurs.last.name}: #{abilities.last.class}")
          hit_stats = abilities.last.execute(dinosaurs.last, dinosaurs.first)
          swapped_out = dinosaurs.last.name if abilities.last.is_swap_out
          node = node.add_or_update_child("#{dinosaurs.last.name}::#{abilities.last.class} #{hit_stats[:is_critical_hit] ? 'crit' : ''}",
            abilities.last.class,
            {
            dinosaur1: dinosaurs.first,
            dinosaur2: dinosaurs.last,
            depth: depth,
            health: health(dinosaurs)
          } )
        end
        if dinosaurs.first.current_health <= 0
          unless apply_damage_over_time(node, dinosaurs, ability_outcomes, abilities, attacker)
            @@logger.info("#{dinosaurs.last.name} wins")
            node.is_final = true
            node.winner = dinosaurs.last.name
            node.looser = dinosaurs.first.name
            node.value = dinosaurs.last.value
            @@logger.info("2: Winner: #{node.winner}, looser: #{node.looser}, attacker: #{attacker.name}, #{node.winner == attacker.name}")
            if dinosaurs.last.name == attacker.name
              # store this as a winning node for the attacker (who may have value -1.0)
              ability_outcomes[abilities.last.class.name] = node.value
            else
              # mark the move above as a loosing move for the attacker
              ability_outcomes[abilities.first.class.name] = node.value
            end
          end
          @@logger.info ability_outcomes
          next
        elsif !swapped_out.empty?
          node.is_final = true
          node.winner = ""
          node.looser = ""
          node.value = dinosaurs.last.value * Constants::MATCH[:swap_out]
          ability_outcomes[abilities.last.class.name] = node.value
          next
        end
        # Advance the clock & apply damage over time and skip to next if both are dead
        next if apply_damage_over_time(node, dinosaurs, ability_outcomes, abilities, attacker)
        # since both survived, explore further into the future
        # the move the dinosaur chose above either leads to a win or a loss further down the line, so we need find the most favourable outcome
        # for the attacker and mark the move chosen above with that outcome
        outcomes = one_round(node, attacker, defender)
        unless outcomes.empty?
          best_outcome = outcomes.sort_by {|k, v| attacker.value * v}.last.last
          worst_outcome = outcomes.sort_by {|k, v| attacker.value * v}.first.last
          if attacker.name == dinosaurs.first.name
            ability_outcomes[abilities.first.class.name] = worst_outcome
          else
            ability_outcomes[abilities.last.class.name] = worst_outcome
          end
          @@logger.info ability_outcomes
        end
      end
    end
    @@logger.info ability_outcomes
    EventSink.add "#{attacker.name} #{ability_outcomes}" if depth == 1
    # At this point we have {"Strike" => 1.0, "EvasiveStance" => -1.0} so we need to pick the best outcome only
    # TODO: we may want to use a random selection or secondary strategy if there or more than one good moves to choose from
    result = [ability_outcomes.sort_by {|k,v| attacker.value * v}.last].to_h rescue {}
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

  # tick both dinosaurs to apply damage over time
  # returns true if one or more are dead, false otherwise
  def self.apply_damage_over_time(node, dinosaurs, ability_outcomes, abilities, attacker)
    dinosaurs.first.tick
    dinosaurs.last.tick
    if dinosaurs.first.current_health <= 0 && dinosaurs.last.current_health <= 0
      @@logger.info("Draw")
      node.is_final = true
      node.winner = nil
      node.looser = nil
      node.value = Constants::MATCH[:draw]
      node.data[:health] = health(dinosaurs)
      if attacker.name == dinosaurs.first.name
        ability_outcomes[abilities.first.class.name] = Constants::MATCH[:draw]
      else
        ability_outcomes[abilities.last.class.name] = Constants::MATCH[:draw]
      end
      return true
    elsif dinosaurs.first.current_health <= 0
      node.is_final = true
      node.winner = dinosaurs.last.name
      node.looser = dinosaurs.first.name
      node.value = dinosaurs.last.value
      node.data[:health] = health(dinosaurs)
      if attacker.name == dinosaurs.first.name
        ability_outcomes[abilities.first.class.name] = node.value
      else
        ability_outcomes[abilities.last.class.name] = node.value
      end
      return true
    elsif dinosaurs.last.current_health <= 0
      node.is_final = true
      node.winner = dinosaurs.first.name
      node.looser = dinosaurs.last.name
      node.value = dinosaurs.first.value
      node.data[:health] = health(dinosaurs)
      if attacker.name == dinosaurs.first.name
        ability_outcomes[abilities.first.class.name] = node.value
      else
        ability_outcomes[abilities.last.class.name] = node.value
      end
      return true
    else
      return false
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

end
