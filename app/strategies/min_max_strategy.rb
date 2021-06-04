# Combination of simulation and min max strategy to bemore efficient and combine caching
require 'logger'

class DummyLogger
  attr_accessor  :log
  def initialize(args)
    @log = []
  end
  def info(args)
    @log << args
  end
end
class MinMaxStrategy

  @@cache = {}
  @@cache_hits = 0
  @@cache_misses = 0
  @@error_rate = 0.0
  @@root = nil
  @@round = 0
  @@logger = Logger.new(STDOUT)

# returns a single availabe ability from the attacker
  def self.next_move(attacker, defender)
    round = 0
    if rand < @@error_rate
      move = attacker.availabe_abilities.sample
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
      move = attacker.available_abilities.select {|a| a.class.name == moves.first.first}.first
    end
    return move
  end

  # returns array of moves with the highest value for the attacker
  def self.one_round(current_node, attacker, defender)
    cache_key = hash_value(current_node)
    if @@cache.key? cache_key
      @@cache_hits += 1
      return @@cache[cache_key]
    end

    # Store the abilities for the attacker and their respective outcome value
    ability_outcomes = {}
    # Safety valve to only look so far into the future
    depth = current_node.data[:depth] + 1
    return if depth > 10
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

        # First attacks
        if dinosaurs.first.is_stunned
          @@logger.info("#{dinosaurs.first.name} is stunned")
          #@log << "#{dinosaurs.first.name}::stunned"
          dinosaurs.first.is_stunned = false
          node = current_node.add_or_update_child( "#{dinosaurs.first.name}::stunned", '', {
            dinosaur1: dinosaurs.first,
            dinosaur2: dinosaurs.last,
            depth: depth,
            health: health(dinosaurs)
          } )
        else
          @@logger.info("#{dinosaurs.first.name}: #{abilities.first.class}")
          #@log << "#{dinosaurs.first.name}::#{abilities.first.class}"
          hit_stats = abilities.first.execute(dinosaurs.first, dinosaurs.last)
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
          node.is_win = true
          node.winner = dinosaurs.first.name
          node.looser = dinosaurs.last.name
          node.value = dinosaurs.first.value
          @@logger.info("1: Winner: #{node.winner}, looser: #{node.looser}, attacker: #{attacker.name}, #{node.winner == attacker.name}")
          if node.winner == attacker.name
            # store this as a winning node for the attacker (who may have value -1.0)
            ability_outcomes[abilities.first.class.name] = node.value
          else
            # store the selection of the attacker as a loss
            ability_outcomes[abilities.last.class.name] = node.value
          end
          @@logger.info ability_outcomes
          break # next rather than break?
        end
        # Second attacks
        if dinosaurs.last.is_stunned
          @@logger.info("#{dinosaurs.last.name} is stunned")
          #@log << "#{dinosaurs.last.name}::stunned"
          dinosaurs.last.is_stunned = false
          node = node.add_or_update_child( "#{dinosaurs.last.name}::stunned", '', {
            dinosaur1: dinosaurs.first,
            dinosaur2: dinosaurs.last,
            depth: depth,
            health: health(dinosaurs)
          })
        else
          @@logger.info("#{dinosaurs.last.name}: #{abilities.last.class}")
          #@log << "#{dinosaurs.last.name}::#{abilities.last.class}"
          hit_stats = abilities.last.execute(dinosaurs.last, dinosaurs.first)
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
          @@logger.info("#{dinosaurs.last.name} wins")
          node.is_win = true
          node.winner = dinosaurs.last.name
          node.looser = dinosaurs.first.name
          node.value = dinosaurs.last.value
          @@logger.info("2: Winner: #{node.winner}, looser: #{node.looser}, attacker: #{attacker.name}, #{node.winner == attacker.name}")
          if node.winner == attacker.name
            # store this as a winning node for the attacker (who may have value -1.0)
            ability_outcomes[abilities.last.class.name] = node.value
          else
            # mark the move above as a loosing move for the attacker
            ability_outcomes[abilities.first.class.name] = node.value
          end
          @@logger.info ability_outcomes
          next
        end
        # Advance the clock
        @@round += 1
        dinosaur1.tick
        dinosaur2.tick
        # since both survived, explore further into the future
        # the move the dinosaur chose above either leads to a win or a loss further down the line, so we need find the most favourable outcome
        # for the attacker and mark the move chosen above with that outcome
        outcomes = one_round(node, attacker, defender)
        unless outcomes.empty?
          best_outcome = outcomes.sort_by {|k, v| attacker.value * v}.last.last
          if attacker.name == dinosaurs.first.name
            ability_outcomes[abilities.first.class.name] = best_outcome
          else
            ability_outcomes[abilities.last.class.name] = best_outcome
          end
          @@logger.info ability_outcomes

        end
      end
    end
    #@logger.info ability_outcomes
    # At this point we have {"Strike" => 1.0, "EvasiveStance" => -1.0} so we need to pick the best outcome only
    # TODO: we may want to use a random selection or secondary strategy if there or more than one good moves to choose from
    result = [ability_outcomes.sort_by {|k,v| attacker.value * v}.last].to_h rescue {}
    # update cache
    @@cache[cache_key] = result
    @@cache_misses += 1
    # return best ability
    return result
  end

  def self.cache_stats
    {size: @@cache.length, hits: @@cache_hits, misses: @@cache_misses}
  end

  def self.reset_cache
    @@cache = {}
    @@cache_hits = 0
    @@cache_misses = 0
  end

  private
  # calculate a unique key for the cache that represents the game state
  def self.hash_value(node)
    d = node.data[:dinosaur1]
    result = "#{d.name} #{d.health} #{d.level} "
    d.abilities.each {|a| result << "#{a.class.name} #{a.current_cooldown} #{a.current_delay} " }
    d.modifiers.each {|m| result << "#{m.class.name} #{m.current_turns} #{m.current_attacks} " }
    d = node.data[:dinosaur2]
    result << "#{d.name} #{d.health} #{d.level} "
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
