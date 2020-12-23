require 'logger'
# Implements a match between two dinosaurs
# Step 1: determine who goes first by speed, level and random
# Step 2: each dinosaur picks a move
# Step 3: first move executed
# Step 4: second move executed
# Step 5: expire effects
# Repeat until one is dead
# Tick represent the rounds inthe match, to be used to expire effects of moves on the opponent after the correct time has expired.
class Match

  def initialize(dinosaur1, dinosaur2)
    @dinosaur1 = dinosaur1.reset_current_attributes!
    @dinosaur2 = dinosaur2.reset_current_attributes!
    @logger = Logger.new(STDOUT)
    @round = 0
  end

  def execute
    while @dinosaur1.current_health > 0 && @dinosaur2.current_health > 0
      dinosaurs = order_moves
      moves = dinosaurs.map{|d| d.pick_move.new(d, (dinosaurs - [d]).first)}
      # @logger.info moves.first.to_s
      moves.first.execute
      break if dinosaurs.last.current_health <= 0
      # @logger.info moves.last.to_s
      moves.last.execute
      break if dinosaurs.last.current_health <= 0
      tick
    end
    @dinosaur1.current_health > 0 ? "#{@dinosaur1.name} wins" : "#{@dinosaur2.name} wins"
  end

  # faster dinosaur wins, if both are equal use level, then random (in games: who pressed faster)
  def order_moves
    retval = @dinosaur1.current_speed > @dinosaur2.current_speed ? [ @dinosaur1, @dinosaur2 ] : [ @dinosaur2, @dinosaur1 ]
    retval.shuffle! if @dinosaur1.current_speed == @dinosaur2.current_speed
    retval
  end

  # Move the clock
  # Update move's delay and cooldown counts
  # Update / expire effects on self and opponents
  def tick
    @round += 1
    @dinosaur1.tick
    @dinosaur2.tick
  end

end
