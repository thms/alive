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
    @dinosaur1.value = 1.0
    @dinosaur2 = dinosaur2.reset_attributes!
    @dinosaur2.value = -1.0
    @logger = Logger.new(STDOUT)
    @logger.level = 2
    @round = 1
    @log = [] # ["D1::Strike", "D2::CleansingStrike", ...]
  end

  def execute
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
        @log << "#{dinosaurs.first.name}::stunned"
        dinosaurs.first.is_stunned = false
        # cooldown whatever the player selected, even if he did not get around to using it
        abilities.first.update_cooldown_attacker(dinosaurs.first, dinosaurs.last)
      else
        @logger.info("#{dinosaurs.first.name}: #{abilities.first.class}")
        @log << "#{dinosaurs.first.name}::#{abilities.first.class}"
        abilities.first.execute(dinosaurs.first, dinosaurs.last)
      end
      break if dinosaurs.last.current_health <= 0
      # Execute counter ability - which may kill the other dinosaur
      if dinosaurs.last.has_counter?
        @logger.info("#{dinosaurs.last.name}: #{dinosaurs.last.abilities_counter.first.class}")
        @log << "#{dinosaurs.last.name}::#{dinosaurs.last.abilities_counter.first.class}"
        dinosaurs.last.abilities_counter.first.execute(dinosaurs.last, dinosaurs.first)
        break if dinosaurs.first.current_health <= 0
      end
      # Second attacks
      if dinosaurs.last.is_stunned
        @logger.info("#{dinosaurs.last.name} is stunned")
        @log << "#{dinosaurs.last.name}::stunned"
        dinosaurs.last.is_stunned = false
        # cooldown whatever the player selected, even if he did not get around to using it
        abilities.last.update_cooldown_attacker(dinosaurs.last, dinosaurs.first)
      else
        @logger.info("#{dinosaurs.last.name}: #{abilities.last.class}")
        @log << "#{dinosaurs.last.name}::#{abilities.last.class}"
        abilities.last.execute(dinosaurs.last, dinosaurs.first)
      end
      break if dinosaurs.first.current_health <= 0
      # Execute counter ability - which may kill the other dinosaur
      if dinosaurs.first.has_counter?
        @logger.info("#{dinosaurs.first.name}: #{dinosaurs.first.abilities_counter.first.class}")
        @log << "#{dinosaurs.first.name}::#{dinosaurs.first.abilities_counter.first.class}"
        dinosaurs.first.abilities_counter.first.execute(dinosaurs.first, dinosaurs.last)
        break if dinosaurs.last.current_health <= 0
      end
      # Advance the clock, to apply DoT and tick down modifiers
      tick
      # After DoT has been applied, we may have a draw, or one of the dinosaurs may have won, so we need to check for it again.
      break if dinosaurs.first.current_health <= 0 && dinosaurs.last.current_health <= 0
    end
    # If we get here, we still need to tick to apply DoT, since this can lead to a draw
    tick
    # three possible outcomes: draw, d1 wins, d2 wins
    if @dinosaur1.current_health <= 0 && @dinosaur2.current_health <= 0
      outcome = 'draw'
      outcome_value = 0.0
    else
      outcome = @dinosaur1.current_health > 0 ? "#{@dinosaur1.name}" : "#{@dinosaur2.name}"
      outcome_value = @dinosaur1.current_health > 0 ? @dinosaur1.value : @dinosaur2.value
    end
    # write the outcome log entry
    @log << outcome
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

  # Move the clock
  # Update abilities' delay and cooldown counts
  # Update / expire effects on self and opponents
  def tick
    @round += 1
    @dinosaur1.tick
    @dinosaur2.tick
  end

end
