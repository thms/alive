require 'logger'
# Implements a match between two dinosaurs
# Step 1: determine who goes first by speed, level and random
# Step 2: each dinosaur picks an ability
# Step 3: first ability executed
# Step 4: second ability executed
# Step 5: expire effects
# Repeat until one is dead
# Tick represent the rounds inthe match, to be used to expire effects of abilities on the opponent after the correct time has expired.
class Match

  def initialize(dinosaur1, dinosaur2)
    @dinosaur1 = dinosaur1.reset_attributes!
    @dinosaur2 = dinosaur2.reset_attributes!
    @logger = Logger.new(STDOUT)
    @round = 0
  end

  def execute
    while @dinosaur1.current_health > 0 && @dinosaur2.current_health > 0
      dinosaurs = order_dinosaurs
      abilities = dinosaurs.map{|d| d.pick_ability.new(d, (dinosaurs - [d]).first)}
      # TODO: if one more more picked a priority move, redo the shuffling
      # @logger.info abilities.first.to_s
      abilities.first.execute
      break if dinosaurs.last.current_health <= 0
      # @logger.info abilities.last.to_s
      abilities.last.execute
      break if dinosaurs.last.current_health <= 0
      # TODO: update all the current attributes before the next round 

      tick
    end
    @dinosaur1.current_health > 0 ? "#{@dinosaur1.name} wins" : "#{@dinosaur2.name} wins"
  end

  # faster dinosaur wins, if both are equal use level, then random (in games: who pressed faster)
  def order_dinosaurs
    retval = @dinosaur1.current_speed > @dinosaur2.current_speed ? [ @dinosaur1, @dinosaur2 ] : [ @dinosaur2, @dinosaur1 ]
    retval.shuffle! if @dinosaur1.current_speed == @dinosaur2.current_speed
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
