require 'test_helper'

class TQStrategyTest < ActiveSupport::TestCase


  test "should return the only available ability without training" do
    d1 = Dinosaur.new(health: 1000, damage: 100, speed: 130, level: 20, name: 'd1', abilities: [Strike], strategy: TQStrategy).reset_attributes!
    d2 = Dinosaur.new(health: 1000, damage: 100, speed: 125, level: 20, name: 'd2', abilities: [Strike], strategy: RandomStrategy).reset_attributes!
    result = TQStrategy.next_move(d1, d2)
    assert_equal Strike, result.class
  end

  test "should return the any available ability without training" do
    d1 = Dinosaur.new(health: 1000, damage: 100, speed: 130, level: 20, name: 'd1', abilities: [Strike, FierceStrike], strategy: TQStrategy).reset_attributes!
    d2 = Dinosaur.new(health: 1000, damage: 100, speed: 125, level: 20, name: 'd2', abilities: [Strike], strategy: RandomStrategy).reset_attributes!
    result = TQStrategy.next_move(d1, d2)
    assert_includes [Strike, FierceStrike], result.class
  end

  test "should learn from a number of games against the random player when going randomly first and last" do
    puts 'TQ : Random'
    stats = HashWithIndifferentAccess.new({d1: 0, d2: 0})
    TQStrategy.reset
    1000.times do
      d1 = Dinosaur.new(health: 1000, damage: 300, speed: 130, level: 20, name: 'd1', abilities: [Strike, Impact], strategy: TQStrategy)
      d2 = Dinosaur.new(health: 1000, damage: 200, speed: 130, level: 20, name: 'd2', abilities: [Strike, Impact], strategy: RandomStrategy)
      match = Match.new(d1, d2)
      result = match.execute
      outcome = result[:winner] == d1.name ? d1.value : d2.value
      TQStrategy.update_q_table(outcome)
      stats[result[:winner]] += 1
    end
    puts "Training: #{stats}"
    pp TQStrategy.stats

    stats = HashWithIndifferentAccess.new({d1: 0, d2: 0})
    100.times do
      d1 = Dinosaur.new(health: 1000, damage: 300, speed: 130, level: 20, name: 'd1', abilities: [Strike, Impact], strategy: TQStrategy)
      d2 = Dinosaur.new(health: 1000, damage: 300, speed: 130, level: 20, name: 'd2', abilities: [Strike, Impact], strategy: RandomStrategy)
      match = Match.new(d1, d2)
      result = match.execute
      outcome = result[:winner] == d1.name ? d1.value : d2.value
      stats[result[:winner]] += 1
    end
    puts "Testing: #{stats}"
    pp TQStrategy.stats

  end
end
