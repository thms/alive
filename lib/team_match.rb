# Match of 4:1
require 'digest'
class TeamMatch

  attr_accessor :attacker
  attr_accessor :defender
  attr_accessor :logger
  attr_accessor :log
  attr_accessor :round

  def initialize(attacker, defender)
    @attacker = attacker.reset_attributes!
    @attacker.value = Constants::MATCH[:max_player]
    @defender = defender.reset_attributes!
    @defender.value = Constants::MATCH[:min_player]
    @round = 0
    @logger = Logger.new(STDOUT)
    @logger.level = 2
    @log = [] # ["T1:D1::Strike", "T2:D2::CleansingStrike", ...]
    @events = []
  end


  def execute
    while !is_win? && @round < 100 # safetly valve only
      @round += 1
      # each team picks a dinosaur and a move.
      abilities = [@attacker.next_move(@defender), @defender.next_move(@attacker)]
      dinosaurs = [@attacker.current_dinosaur, @defender.current_dinosaur]
      # order the dinosaurs by level, speeds etc
      order_dinosaurs_and_abilities(dinosaurs, abilities)

      # first one attacks
      if dinosaurs.first.is_stunned
        @log << {event: "#{dinosaurs.first.name}::stunned", stats:{}, health: health(dinosaurs)}
        @events << {event: "#{dinosaurs.first.name}::stunned", stats:{}, health: health(dinosaurs)}
        dinosaurs.first.is_stunned = false
        # cooldown whatever the player selected, even if he did not get around to using it
        abilities.first.update_cooldown_attacker(dinosaurs.first, dinosaurs.last)
      else
        hit_stats = abilities.first.execute(dinosaurs.first, dinosaurs.last)
        @log << {event: "#{dinosaurs.first.name}::#{abilities.first.class}", stats: hit_stats, health: health(dinosaurs)}
        @events << {event: "#{dinosaurs.first.name}::#{abilities.first.class}", stats: hit_stats, health: health(dinosaurs)}
        if abilities.first.is_swap_out
          team = dinosaurs.first.team
          name = dinosaurs.first.name
          if dinosaurs.first.run
            dinosaurs[0] = team.current_dinosaur
            @events << {event: "#{name} swapped out", stats: {}, health: health(dinosaurs)}
          else
            @events << {event: "#{name} prevented from swapping out", stats: {}, health: health(dinosaurs)}
          end
        end
      end
      # if that leads to death, the round ends and the team will attempt to pick a new dinosaur, but we also need to tick down the other dinosaur
      if dinosaurs.first.current_health <= 0 || dinosaurs.last.current_health <= 0
        apply_damage_over_time(dinosaurs)
        if is_win?
          # match is over
          break
        else
          next
        end
      end
      # second one attacks
      if dinosaurs.last.is_stunned
        @log << {event: "#{dinosaurs.last.name}::stunned", stats:{}, health: health(dinosaurs)}
        @events << {event: "#{dinosaurs.last.name}::stunned", stats:{}, health: health(dinosaurs)}
        dinosaurs.last.is_stunned = false
        # cooldown whatever the player selected, even if he did not get around to using it
        abilities.last.update_cooldown_attacker(dinosaurs.last, dinosaurs.first)
      else
        hit_stats = abilities.last.execute(dinosaurs.last, dinosaurs.first)
        @log << {event: "#{dinosaurs.last.name}::#{abilities.last.class}", stats: hit_stats, health: health(dinosaurs)}
        @events << {event: "#{dinosaurs.last.name}::#{abilities.last.class}", stats: hit_stats, health: health(dinosaurs)}
        if abilities.last.is_swap_out
          if dinosaurs.last.team.run
            @events << {event: "#{dinosaurs.last.name} swapped out", stats: {}, health: health(dinosaurs)}
          else
            @events << {event: "#{dinosaurs.last.name} prevented from swapping out", stats: {}, health: health(dinosaurs)}
          end
        end

      end
      # if that leads to death, the round ends
      if dinosaurs.first.current_health <= 0 || dinosaurs.last.current_health <= 0
        apply_damage_over_time(dinosaurs)
        if is_win?
          break
        else
          next
        end
      end
      # neither has died, tick down both before the next round
      dinosaurs.first.tick
      dinosaurs.last.tick
    end
    # three possible outcomes: draw, attacker wins, defender wins
    if @attacker.healthy_members <= 1 && @defender.healthy_members <= 1
      outcome = 'draw'
      outcome_value = Constants::MATCH[:draw]
    else
      outcome = @attacker.healthy_members > 1 ? "#{@attacker.name}" : "#{@defender.name}"
      outcome_value = @attacker.healthy_members > 1 ? @attacker.value : @defender.value
    end
    # write the outcome log entry
    @log << {event: outcome, stats: {}, health: health(dinosaurs)}
    @events << {event: outcome, stats: {}, health: health(dinosaurs)}
    {outcome: outcome, outcome_value: outcome_value, log: @log, events: @events}

  end

  def apply_damage_over_time(dinosaurs)
    dinosaurs.first.tick
    dinosaurs.last.tick
  end

  # faster dinosaur wins, if both are equal use level, then random (in games: who pressed faster)
  def order_dinosaurs_and_abilities(dinosaurs, abilities)
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
    @attacker.healthy_members <= 1 || @defender.healthy_members <= 1
  end

  def health(dinosaurs)
    if dinosaurs.first.name < dinosaurs.last.name
      return "#{dinosaurs.first.name}:#{dinosaurs.first.current_health}, #{dinosaurs.last.name}:#{dinosaurs.last.current_health}"
    else
      return "#{dinosaurs.last.name}:#{dinosaurs.last.current_health}, #{dinosaurs.first.name}:#{dinosaurs.first.current_health}"
    end
  end

  # Hash value expressing the state of the game
  def self.hash_value(attacker, defender)
    result = ""
    result += "#{attacker.value} #{attacker.hash_value} "
    result += attacker.current_dinosaur.nil? ? "-" : attacker.current_dinosaur.name
    result += " #{defender.value} #{defender.hash_value} "
    result += defender.current_dinosaur.nil? ? "-" : defender.current_dinosaur.name
  end

end
