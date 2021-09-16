# Implements a blended strategy that evaluates several strategies and blends their results
require 'logger'

class BlendedStrategy < Strategy

  STRATEGIES = [MinMaxStrategy, MinMax2Strategy, ForcedStrategy]
  @@logger = Logger.new(STDOUT)
  @@logger.level = :warn
  @@log = []
  @@error_rate = 0.0
  @@games_played = 0

  def self.next_move(attacker, defender)
    @@games_played += 1
    if rand < @@error_rate
      move = attacker.availabe_abilities.sample
      EventSink.add "#{attacker.name}: #{move.class.name} - random"
    elsif attacker.available_abilities.size == 1
      move = attacker.available_abilities.first
      EventSink.add "#{attacker.name}: #{move.class.name} - only choice"
    else
      results = []
      STRATEGIES.each do |strategy|
        # select best possible move
        root = Node.new('Start')
        root.data = {
          dinosaur1: attacker,
          dinosaur2: defender,
          depth: 0
        }
        # Keep attacker and defender always ordered like that
        results.push strategy.one_round(root, attacker, defender)
        @@logger.info("Moves: #{results.last[:ability_outcomes]}")
      end
      # Combine results from all strategies
      result = {value: 0.0, ability_outcomes: attacker.available_abilities.map {|a| [a.class.name, 0.0]}.to_h}
      results.each do |r|
        r[:ability_outcomes].each do |k,v|
          result[:ability_outcomes][k] += v
        end
        result[:value] += r[:value]
      end
      @@logger.warn results
      @@logger.warn result
      EventSink.add "#{attacker.name}: #{result[:ability_outcomes]}"
      # pick one of the best moves if there are more than one with the same best value
      if attacker.value == 1.0
        best_outcome = result[:ability_outcomes].values.max
        result[:ability_outcomes].delete_if {|k,v| v < best_outcome}
      else
        best_outcome = result[:ability_outcomes].values.min
        result[:ability_outcomes].delete_if {|k,v| v > best_outcome}
      end
      ability_name = result[:ability_outcomes].keys.sample
      move = attacker.available_abilities.select {|a| a.class.name == ability_name}.first
    end
    return move
  end

  def self.learn(outcome, attacker_value)
    STRATEGIES.each do |strategy|
      strategy.learn(outcome, attacker_value)
    end
  end

  def self.reset
    STRATEGIES.each do |strategy|
      strategy.reset
    end
  end
end
