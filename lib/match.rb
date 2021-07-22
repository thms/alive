require 'logger'
# Implements a match between two dinosaurs
# Step 1: determine who goes first by speed, level and random
# Step 2: each dinosaur picks an ability
# Step 3: first ability executed
# Step 4: second ability executed
# Step 5: expire modifiers
# Repeat until one is dead
# Tick represent the rounds in the match, to be used to expire effects of abilities on the opponent after the correct time has expired.
class Match

  def initialize(dinosaur1, dinosaur2)
    @dinosaur1 = dinosaur1.reset_attributes!
    @dinosaur1.value = Constants::MATCH[:max_player]
    @dinosaur2 = dinosaur2.reset_attributes!
    @dinosaur2.value = Constants::MATCH[:min_player]
    @logger = Logger.new(STDOUT)
    @logger.level = :info
    @round = 1
    @log = [] # [{event: "D1::Strike", stats: {}, health: {}}, {event: "D2::CleansingStrike" stats: , ...]
  end

  def execute
    swapped_out = nil
    while @dinosaur1.current_health > 0 && @dinosaur2.current_health > 0
      # Each picks an ability to use
      @dinosaur1.pick_ability(@dinosaur1, @dinosaur2)
      @dinosaur2.pick_ability(@dinosaur2, @dinosaur1)
      # order them by speed, to decide who goes first
      dinosaurs = order_dinosaurs

      # First attacks
      swapped_out = attack(dinosaurs.first, dinosaurs.last)
      # matchs ends if either is dead or first has swapped out
      if has_ended?(dinosaurs) || !swapped_out.nil?
        apply_damage_over_time
        break
      end

      # Second attacks
      swapped_out = attack(dinosaurs.last, dinosaurs.first)
      # match ends if either is dead or second has swapped out
      if has_ended?(dinosaurs) || !swapped_out.nil?
        apply_damage_over_time
        break
      end

      # end of the round, both are still alive, apply DoT
      apply_damage_over_time
      break if has_ended?(dinosaurs)
      # if both are still alive, tick down modifiers and head into the next round
      tick
    end

    # if damage over time has changed the health from the last log entry write another log entry
    if health(dinosaurs) != @log.last[:health]
      @log << {event: "DoT", stats: {}, health: health(dinosaurs)}
    end
    # four possible outcomes: draw, d1 wins, d2 wins, one dino swapped out
    determine_outcome
  end

  def determine_outcome
    # four possible outcomes: draw, d1 wins, d2 wins, one dino swapped out
    if @dinosaur1.current_health <= 0 && @dinosaur2.current_health <= 0
      outcome = 'draw'
      outcome_value = Constants::MATCH[:draw]
    elsif @dinosaur1.current_health == 0 || @dinosaur2.current_health == 0
      outcome = @dinosaur1.current_health > 0 ? "#{@dinosaur1.name}" : "#{@dinosaur2.name}"
      outcome_value = @dinosaur1.current_health > 0 ? @dinosaur1.value : @dinosaur2.value
    elsif !swapped_out.empty?
      outcome = "#{swapped_out} swapped out"
      outcome_value  = Constants::MATCH[:swap_out] * (@dinosaur1.name == swapped_out ? @dinosaur1.value : @dinosaur2.value)
    end
    # write the outcome log entry
    @log << {event: outcome, stats: {}, health: health([@dinosaur1, @dinosaur2])}
    {outcome: outcome, outcome_value: outcome_value, log: @log}
  end

  # returns true if the match has ended, false otherwise
  def has_ended?(dinosaurs)
    dinosaurs.any? {|d| d.current_health <= 0}
  end

  # faster dinosaur wins, if both are equal use level, then random (in games: who pressed faster)
  def order_dinosaurs
    if @dinosaur1.current_speed == @dinosaur2.current_speed
      dinosaurs = @dinosaur1.level > @dinosaur2.level ? [ @dinosaur1, @dinosaur2 ] : [ @dinosaur2, @dinosaur1 ]
      dinosaurs.shuffle! if @dinosaur1.level == @dinosaur2.level
    else
      dinosaurs = @dinosaur1.current_speed > @dinosaur2.current_speed ? [ @dinosaur1, @dinosaur2 ] : [ @dinosaur2, @dinosaur1 ]
    end
    # if the second picked priority move and the first one did not, swap them around
    # in all other cases they are already in the correct order
    if dinosaurs.last.selected_ability.is_priority && !dinosaurs.first.selected_ability.is_priority
      dinosaurs.reverse!
    end
    dinosaurs
  end

  def attack(attacker, defender)
    swapped_out = nil
    if attacker.is_stunned
      @logger.info("#{attacker.name} is stunned")
      # update cooldown on what the attacker selected, even if he did not get around to use it
      attacker.selected_ability.update_cooldown_attacker(attacker, defender)
      # replace with do nothing ability
      attacker.selected_ability = IsStunned.new
    end
    hit_stats = attacker.selected_ability.execute(attacker, defender)
    @log << {event: "#{attacker.name}::#{attacker.selected_ability.class}", stats: hit_stats, health: health([attacker, defender])}
    @logger.info("#{attacker.name}: #{attacker.selected_ability.class}")
    swapped_out = attacker.name if attacker.selected_ability.is_swap_out
    @logger.info("#{attacker.name}: swapped_out") unless swapped_out.nil?
    return swapped_out
  end

  def health(dinosaurs)
    if dinosaurs.first.name < dinosaurs.last.name
      return "#{dinosaurs.first.name}:#{dinosaurs.first.current_health}, #{dinosaurs.last.name}:#{dinosaurs.last.current_health}"
    else
      return "#{dinosaurs.last.name}:#{dinosaurs.last.current_health}, #{dinosaurs.first.name}:#{dinosaurs.first.current_health}"
    end
  end

  def hash_value(dinosaurs)
    "#{dinosaurs.first.value} #{dinosaurs.first.hash_value} #{dinosaurs.last.value} #{dinosaurs.last.hash_value}"
  end

  # Move the clock
  # Update abilities' delay and cooldown counts
  # Update / expire effects on self and opponents
  def tick
    @round += 1
    @dinosaur1.tick
    @dinosaur2.tick
  end

  def apply_damage_over_time
    @dinosaur1.apply_damage_over_time
    @dinosaur2.apply_damage_over_time
  end

end
