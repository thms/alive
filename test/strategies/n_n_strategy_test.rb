require 'test_helper'

class NNStrategyTest < ActiveSupport::TestCase

  test "should learn from a number of games against the default player " do
    skip
    puts 'NN : Default'
    stats = HashWithIndifferentAccess.new({d1: 0, d2: 0, draw: 0})
    NNStrategy.reset
    500.times do
      d1 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 130, level: 20, name: 'd1', abilities: [Strike, Impact], resistances: [0, 50, 0, 0, 0, 34, 0, 100, 0], strategy: NNStrategy)
      d2 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 130, level: 20, name: 'd2', abilities: [Strike, Impact], resistances: [0, 50, 0, 0, 0, 34, 0, 100, 0], strategy: DefaultStrategy)
      match = Match.new(d1, d2)
      result = match.execute
      NNStrategy.learn(result[:outcome_value])
      stats[result[:outcome]] += 1
    end
    puts "Training: #{stats}"

    stats = HashWithIndifferentAccess.new({d1: 0, d2: 0, draw: 0})
    log = []
    100.times do
      d1 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 130, level: 20, name: 'd1', abilities: [Strike, Impact], resistances: [0, 50, 0, 0, 0, 34, 0, 100, 0], strategy: NNStrategy)
      d2 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 130, level: 20, name: 'd2', abilities: [Strike, Impact], resistances: [0, 50, 0, 0, 0, 34, 0, 100, 0], strategy: DefaultStrategy)
      match = Match.new(d1, d2)
      result = match.execute
      log.push result[:log]
      stats[result[:outcome]] += 1
    end
    puts "Testing: #{stats}"
  end

  test "should learn from a number of games against the random player " do
    skip
    puts 'NN : Random'
    stats = HashWithIndifferentAccess.new({d1: 0, d2: 0, draw: 0})
    NNStrategy.reset
    1000.times do
      d1 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 132, level: 20, name: 'd1', abilities: [Strike, Impact], resistances: [0, 50, 0, 0, 0, 34, 0, 100, 0], strategy: NNStrategy)
      d2 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 130, level: 20, name: 'd2', abilities: [Strike, Impact], resistances: [0, 50, 0, 0, 0, 34, 0, 100, 0], strategy: RandomStrategy)
      match = Match.new(d1, d2)
      result = match.execute
      NNStrategy.learn(result[:outcome_value])
      stats[result[:outcome]] += 1
    end
    puts "Training: #{stats}"

    stats = HashWithIndifferentAccess.new({d1: 0, d2: 0, draw: 0})
    log = []
    100.times do
      d1 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 132, level: 20, name: 'd1', abilities: [Strike, Impact], resistances: [0, 50, 0, 0, 0, 34, 0, 100, 0], strategy: NNStrategy)
      d2 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 130, level: 20, name: 'd2', abilities: [Strike, Impact], resistances: [0, 50, 0, 0, 0, 34, 0, 100, 0], strategy: RandomStrategy)
      match = Match.new(d1, d2)
      result = match.execute
      log.push result[:log]
      stats[result[:outcome]] += 1
    end
    puts "Testing: #{stats}"
  end

  test "should learn from a number of games against the Min max player " do
    #skip
    name1 = 'Geminititan'
    name2 = 'Thoradolosaur'
    puts "#{name1} : #{name2}"
    stats = HashWithIndifferentAccess.new({name1 => 0, name2 => 0, draw: 0})
    NNStrategy.reset
    MinMaxStrategy.reset
    100.times do
      d1 = Dinosaur.find_by_name(name1)
      d1.strategy = NNStrategy
      d2 = Dinosaur.find_by_name(name2)
      d2.strategy = MinMaxStrategy
      match = Match.new(d1, d2)
      result = match.execute
      NNStrategy.learn(result[:outcome_value])
      stats[result[:outcome]] += 1
    end
    puts "Training: #{stats}"

    # stats = HashWithIndifferentAccess.new({name1 => 0, name2 => 0, draw: 0})
    # log = []
    # 10.times do
    #   d1 = Dinosaur.find_by_name(name1)
    #   d1.strategy = NNStrategy
    #   d2 = Dinosaur.find_by_name(name2)
    #   d2.strategy = MinMaxStrategy
    #   match = Match.new(d1, d2)
    #   result = match.execute
    #   log.push result[:log]
    #   stats[result[:outcome]] += 1
    # end
    # puts "Testing: #{stats}"
    # puts NNStrategy.stats
  end

end
