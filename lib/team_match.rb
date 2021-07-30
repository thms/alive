# Match of 4:4 or similar
require 'digest'
class TeamMatch

  attr_accessor :attacker
  attr_accessor :defender
  attr_accessor :logger
  attr_accessor :log
  attr_accessor :round
  attr_accessor :mode # :pvp, :campaign, :raid

  def initialize(attacker, defender, mode = :pvp)
    @attacker = attacker.reset_attributes!
    @attacker.value = Constants::MATCH[:max_player]
    @defender = defender.reset_attributes!
    @defender.value = Constants::MATCH[:min_player]
    @round = 1
    @logger = Logger.new(STDOUT)
    @logger.level = :warn
    @log = [] # ["T1:D1::Strike", "T2:D2::CleansingStrike", ...]
    @events = []
    @mode = mode
  end


  def execute
    while !TeamMechanics.has_ended?(@attacker, @defender, @mode) && @round < 100 # safety valve only
      # each team picks a dinosaur and an ability.
      @attacker.next_move(@defender)
      @defender.next_move(@attacker)
      # order the dinosaurs by level, speeds etc
      dinosaurs = Mechanics.order_dinosaurs([@attacker.current_dinosaur, @defender.current_dinosaur])

      # first one attacks
      TeamMechanics.attack(dinosaurs.first, dinosaurs.last, @log, @events)
      # at this point the match may be over, the round may be over or we may continue
      # , the round ends and the team will attempt to pick a new dinosaur, but we also need to tick down the other dinosaur
      if TeamMechanics.has_ended?(@attacker, @defender, @mode) || (dinosaurs.first.current_health == 0 || dinosaurs.last.current_health == 0)
        Mechanics.apply_damage_over_time(dinosaurs)
        # Check again if the match has now ended
        if TeamMechanics.has_ended?(@attacker, @defender, @mode)
          # match is over
          break
        else
          # one is still alive, so tick down and enter the next round
          Mechanics.tick(dinosaurs)
          next
        end
      end
      # second one attacks
      TeamMechanics.attack(dinosaurs.last, dinosaurs.first, @log, @events)
      # at this point the match may be over, the round may be over or we may continue
      # , the round ends and the team will attempt to pick a new dinosaur, but we also need to tick down the other dinosaur
      if TeamMechanics.has_ended?(@attacker, @defender, @mode) || (dinosaurs.first.current_health == 0 || dinosaurs.last.current_health == 0)
        Mechanics.apply_damage_over_time(dinosaurs)
        # Check again if the match has now ended
        if TeamMechanics.has_ended?(@attacker, @defender, @mode)
          # match is over
          break
        else
          # one is still alive, so tick down and enter the next round
          Mechanics.tick(dinosaurs)
          next
        end
      end
      # neither has died, apply damage over time
      Mechanics.apply_damage_over_time(dinosaurs)
      # match ends if either team is defeated
      break if TeamMechanics.has_ended?(@attacker, @defender, @mode)
      # tick down both before the next round
      Mechanics.tick(dinosaurs)
      @round += 1
    end
    # three possible outcomes: draw, attacker wins, defender wins
    outcome, outcome_value = TeamMechanics.determine_outcome(@attacker, @defender, @mode)
    # write the outcome log entry
    @log << {event: outcome, stats: {}, health: Mechanics.health(dinosaurs)}
    @events << {event: outcome, stats: {}, health: Mechanics.health(dinosaurs)}
    EventSink.add "#{@attacker.health} : #{@defender.health}"
    {outcome: outcome, outcome_value: outcome_value, log: @log, events: @events}
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
