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
    @logger.level = :warn
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
      dinosaurs = Mechanics.order_dinosaurs([@dinosaur1, @dinosaur2])

      # First attacks
      hits_stats, swapped_out = Mechanics.attack(dinosaurs.first, dinosaurs.last, @log, @logger)
      # matchs ends if either is dead or first has swapped out
      if Mechanics.has_ended?(dinosaurs) || !swapped_out.nil?
        Mechanics.apply_damage_over_time(dinosaurs)
        break
      end

      # Second attacks
      hit_stats, swapped_out = Mechanics.attack(dinosaurs.last, dinosaurs.first, @log, @logger)
      # match ends if either is dead or second has swapped out
      if Mechanics.has_ended?(dinosaurs) || !swapped_out.nil?
        Mechanics.apply_damage_over_time(dinosaurs)
        break
      end

      # end of the round, both are still alive, apply DoT
      Mechanics.apply_damage_over_time(dinosaurs)
      break if Mechanics.has_ended?(dinosaurs)
      # if both are still alive, tick down modifiers and head into the next round
      Mechanics.tick(dinosaurs)
      @round += 1
    end

    # if damage over time has changed the health from the last log entry write another log entry
    if Mechanics.health(dinosaurs) != @log.last[:health]
      @log << {event: "DoT", stats: {}, health: Mechanics.health(dinosaurs)}
    end
    Mechanics.determine_outcome(dinosaurs, swapped_out, @log)
  end




end
