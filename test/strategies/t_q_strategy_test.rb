require 'test_helper'

class TQStrategyTest < ActiveSupport::TestCase


  test "should return the only available ability without training" do
    skip
    d1 = Dinosaur.new(health_26: 1000, damage_26: 100, speed: 130, level: 20, name: 'd1', abilities: [Strike], strategy: TQStrategy).reset_attributes!
    d2 = Dinosaur.new(health_26: 1000, damage_26: 100, speed: 125, level: 20, name: 'd2', abilities: [Strike], strategy: RandomStrategy).reset_attributes!
    result = TQStrategy.next_move(d1, d2)
    assert_equal Strike, result.class
  end

  test "should return the any available ability without training" do
    skip
    d1 = Dinosaur.new(health_26: 1000, damage_26: 100, speed: 130, level: 20, name: 'd1', abilities: [Strike, FierceStrike], strategy: TQStrategy).reset_attributes!
    d2 = Dinosaur.new(health_26: 1000, damage_26: 100, speed: 125, level: 20, name: 'd2', abilities: [Strike], strategy: RandomStrategy).reset_attributes!
    result = TQStrategy.next_move(d1, d2)
    assert_includes [Strike, FierceStrike], result.class
  end

  test "training should propagate backwards" do
    #skip
    TQStrategy.reset
    TQStrategy.enable_random_mode
    d1 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 130, level: 20, name: 'd1', abilities: [Strike, FierceStrike], strategy: TQStrategy).reset_attributes!
    d2 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 130, level: 20, name: 'd2', abilities: [Strike], strategy: RandomStrategy).reset_attributes!
    match = Match.new(d1, d2)
    result = match.execute
    outcome = result[:outcome] == d1.name ? d1.value : d2.value
    puts "Outcome: #{outcome}"
    log = TQStrategy.log.clone
    TQStrategy.learn(result[:outcome_value], d1.value)
    # replay the game
    TQStrategy.set_log(log)
    TQStrategy.learn(result[:outcome_value], d1.value)

  end

  test "should learn from a number of games against the random player when going randomly first and last" do
    #skip
    puts 'TQ : Random'
    stats = HashWithIndifferentAccess.new({d1: 0, d2: 0, draw: 0})
    TQStrategy.reset
    100.times do
      d1 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 130, level: 20, name: 'd1', abilities: [Strike, Impact], strategy: DefaultStrategy)
      d2 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 130, level: 20, name: 'd2', abilities: [Strike, Impact], strategy: TQStrategy)
      match = Match.new(d1, d2)
      result = match.execute
      TQStrategy.learn(result[:outcome_value], d2.value)
      stats[result[:outcome]] += 1
    end
    puts "Training: #{stats}"

    stats = HashWithIndifferentAccess.new({d1: 0, d2: 0, draw: 0})
    log = []
    100.times do
      d1 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 130, level: 20, name: 'd1', abilities: [Strike, Impact], strategy: DefaultStrategy)
      d2 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 130, level: 20, name: 'd2', abilities: [Strike, Impact], strategy: TQStrategy)
      match = Match.new(d1, d2)
      result = match.execute
      log.push result[:log]
      stats[result[:outcome]] += 1
    end
    puts "Testing: #{stats}"
  end

  test "should save state to disk and load back" do
    skip
    TQStrategy.reset
    10.times do
      d1 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 130, level: 20, name: 'd1', abilities: [Strike, Impact], strategy: DefaultStrategy)
      d2 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 130, level: 20, name: 'd2', abilities: [Strike, Impact], strategy: TQStrategy)
      match = Match.new(d1, d2)
      result = match.execute
      TQStrategy.learn(result[:outcome_value], d2.value)
    end
    TQStrategy.save
    games_played = TQStrategy.games_played
    TQStrategy.reset
    assert_equal 0, TQStrategy.games_played
    TQStrategy.load
    assert_equal games_played, TQStrategy.games_played
  end

end
