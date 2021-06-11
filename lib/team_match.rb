# Match of 4:1
class TeamMatch

  attr_accessor :attacker
  attr_accessor :defender
  attr_accessor :logger
  attr_accessor :log
  attr_accessor :round

  def initialize(attacker, defender)
    @attacker = attacker.reset_attributes!
    @attacker.value = 1.0
    @defender = defender.reset_attributes!
    @defender.value = -1.0
    @round = 0
    @logger = Logger.new(STDOUT)
    @logger.level = 1
    @log = [] # ["T1:D1::Strike", "T2:D2::CleansingStrike", ...]
  end


  def execute
    while !is_win? && @round < 100 # safetly valve only
      @round += 1
      @logger.info("Round: #{@round}")
      @logger.info("Attacker #{@attacker.health}")
      @logger.info("Defender #{@defender.health}")
      # each team picks a dinosaur and a move.
      abilities = [attacker.next_move(defender), defender.next_move(attacker)]
      dinosaurs = [attacker.current_dinosaur, defender.current_dinosaur]
      # order the dinosaurs by level, speeds etc
      order_dinosaurs_and_abilities(dinosaurs, abilities)

      # first one attacks
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
      # if that leads to death, the round ends and the team will attempt to pick a new dinosaur, but we also need to tick down the other dinosaur
      if dinosaurs.last.current_health <= 0
        dinosaurs.first.tick
        if is_win?
          break
        else
          next
        end
      end
      # second one attacks
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
      # if that leads to death, the round ends
      if dinosaurs.first.current_health <= 0
        dinosaurs.last.tick
        if is_win?
          break
        else
          next
        end
      end
    end
    # three possible outcomes: draw, attacker wins, defender wins
    if @attacker.current_health <= 1 && @defender.current_health <= 1
      outcome = 'draw'
      outcome_value = 0.0
    else
      outcome = @attacker.current_health > 1 ? "#{@attacker.name}" : "#{@defender.name}"
      outcome_value = @attacker.current_health > 1 ? @attacker.value : @defender.value
    end
    # write the outcome log entry
    @log << outcome
    {outcome: outcome, outcome_value: outcome_value, log: @log}

  end

  # faster dinosaur wins, if both are equal use level, then random (in games: who pressed faster)
  def order_dinosaurs_and_abilities(dinosaurs, abilities)
    @logger.info(dinosaurs.map {|d| d.name})

    if dinosaurs.first.current_speed == dinosaurs.last.current_speed
      if dinosaurs.first.level < dinosaurs.last.level
        # same speed but different level, higher level goes first
        dinosaurs.reverse!
        abilities.reverse!
      elsif dinosaurs.first.level == dinosaurs.last.level && rand < 0.5
        # random order if level and speed are the same
        dinosaurs.reverse!
        abilities.reverse!
      end
    else
      if dinosaurs.first.current_speed < dinosaurs.last.current_speed
        # faster goes always first
        dinosaurs.reverse!
        abilities.reverse!
      end
    end
    # handle priority moves
    # if the second picked priority move and the first one did not, swap them around
    # in all other cases they are already in the correct order
    if abilities.last.is_priority && !abilities.first.is_priority
      dinosaurs.reverse!
      abilities.reverse!
    end
  end

  # Is the current state a win for one of the teams?
  def is_win?
    @attacker.current_health <= 1 || @defender.current_health <= 1
  end

end
