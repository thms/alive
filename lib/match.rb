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
    @logger.level = 2
    @round = 1
    @log = [] # [{event: "D1::Strike", stats: {}, health: {}}, {event: "D2::CleansingStrike" stats: , ...]
  end

  def execute
    swapped_out = ""
    while @dinosaur1.current_health > 0 && @dinosaur2.current_health > 0
      @logger.info("Round: #{@round}")
      @logger.info("#{@dinosaur1.name}: #{@dinosaur1.current_speed}")
      @logger.info("#{@dinosaur2.name}: #{@dinosaur2.current_speed}")
      # order them by speed, to decide who goes first
      dinosaurs = order_dinosaurs
      # Each picks an ability to use
      abilities = []
      abilities << dinosaurs.first.pick_ability(dinosaurs.first, dinosaurs.last)
      abilities << dinosaurs.last.pick_ability(dinosaurs.last, dinosaurs.first)
      # if the second picked priority move and the first one did not, swap them around
      # in all other cases they are already in the correct order
      if abilities.last.is_priority && !abilities.first.is_priority
        dinosaurs.reverse!
        abilities.reverse!
      end
      # First attacks
      if dinosaurs.first.is_stunned
        @logger.info("#{dinosaurs.first.name} is stunned")
        @log << {event: "#{dinosaurs.first.name}::stunned", stats:{}, health: health(dinosaurs)}
        dinosaurs.first.is_stunned = false
        # cooldown whatever the player selected, even if he did not get around to using it
        abilities.first.update_cooldown_attacker(dinosaurs.first, dinosaurs.last)
      else
        hit_stats = abilities.first.execute(dinosaurs.first, dinosaurs.last)
        swapped_out = dinosaurs.first.name if abilities.first.is_swap_out
        @logger.info("#{dinosaurs.first.name}: #{abilities.first.class}")
        @log << {event: "#{dinosaurs.first.name}::#{abilities.first.class}", stats: hit_stats, health: health(dinosaurs)}
      end
      break if dinosaurs.first.current_health <= 0 || dinosaurs.last.current_health <= 0 || !swapped_out.empty?

      # Second attacks
      if dinosaurs.last.is_stunned
        @logger.info("#{dinosaurs.last.name} is stunned")
        @log << {event: "#{dinosaurs.last.name}::stunned", stats:{}, health: health(dinosaurs)}
        dinosaurs.last.is_stunned = false
        # cooldown whatever the player selected, even if he did not get around to using it
        abilities.last.update_cooldown_attacker(dinosaurs.last, dinosaurs.first)
      else
        hit_stats = abilities.last.execute(dinosaurs.last, dinosaurs.first)
        swapped_out = dinosaurs.last.name if abilities.last.is_swap_out
        @logger.info("#{dinosaurs.last.name}: #{abilities.last.class}")
        @log << {event: "#{dinosaurs.last.name}::#{abilities.last.class}", stats: hit_stats, health: health(dinosaurs)}
      end
      break if dinosaurs.first.current_health <= 0 || dinosaurs.last.current_health <= 0 || !swapped_out.empty?
      # Advance the clock, to apply DoT and tick down modifiers
      tick
      # After DoT has been applied, we may have a draw, or one of the dinosaurs may have won, so we need to check for it again.
      break if dinosaurs.first.current_health <= 0 && dinosaurs.last.current_health <= 0
    end
    # If we get here, we still need to tick to apply DoT, since this can lead to a draw
    tick
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
    @log << {event: outcome, stats: {}, health: health(dinosaurs)}
    {outcome: outcome, outcome_value: outcome_value, log: @log}
  end

  # faster dinosaur wins, if both are equal use level, then random (in games: who pressed faster)
  def order_dinosaurs
    if @dinosaur1.current_speed == @dinosaur2.current_speed
      retval = @dinosaur1.level > @dinosaur2.level ? [ @dinosaur1, @dinosaur2 ] : [ @dinosaur2, @dinosaur1 ]
      retval.shuffle! if @dinosaur1.level == @dinosaur2.level
    else
      retval = @dinosaur1.current_speed > @dinosaur2.current_speed ? [ @dinosaur1, @dinosaur2 ] : [ @dinosaur2, @dinosaur1 ]
    end
    retval
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

end
