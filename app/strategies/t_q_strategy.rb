require 'logger'
# Tabular Q Function strategy
# Learning over teh course of a numbe of games what works best in a gven state of the game
# Inputs to learning: state == attacker, defender
# outputs: value for each of the dinosaurs abilties (max of four per dinosaur)
# Q_Table stores a hash of the availble abilities to the q value : {"CunningStrike" => 0.3, "FierceImpact" => 0.6}
class TQStrategy

  INITIAL_Q_VALUE = 0.2
  EPSILON = 0.05
  @@q_table = {}
  @@log = []
  @@value = 1.0
  @@random_mode = false
  @@logger = Logger.new(STDOUT)
  @@logger.level = 2 # 1: show info, 2: don't show info

  def self.next_move(attacker, defender)
    available_ability_names = attacker.available_abilities.map {|a| a.class.name }
    # abilities according to the Q table
    abilities = @@q_table[hash_value(attacker, defender)]
    # if empty, initialize and pick a random available ability
    if abilities.nil?
      @@q_table[hash_value(attacker, defender)] = available_ability_names.map {|a| [a, INITIAL_Q_VALUE]}.to_h
      ability = attacker.available_abilities.sample.class.name
    elsif @@random_mode || rand < EPSILON
      # pick a random ability to do a broad learning in initial training
      ability = available_ability_names.sample
    else
      # What is the highest value
      highest_value = abilities.sort_by {|k, v| v}.last.last
      # find all moves that have the highest value and pick one at random
      ability = abilities.map {|k, v| highest_value == v ? k : nil}.compact.sample
    end
    @@log.push [hash_value(attacker, defender), available_ability_names, attacker.value, ability]
    # Return the actual ability instance of the attacker
    return attacker.abilities.select {|a| a.class.name == ability}.first
  end

  # log is an array of shape: [[hash, attacker, defender before action, player value, action]], outcome is 0.0, 0.5 or 1.0
  # distribute reward backwards from the last move with discount and apply learning
  # action is "FierceStrike", etc
  # player value = 1.0 or -1.0
  # log does not include the final state of the game, since it is not needed for training
  def self.update_q_table(outcome)
    learning_rate = 0.01
    discount = 0.95
    max_a = (1.0 + @@value * outcome)/2.0
    last_entry = true
    while entry = @@log.pop
      hash_value = entry[0]
      available_ability_names = entry[1]
      action = entry[3]
      # initialise q_table if not yet done
      @@q_table[hash_value] = available_ability_names.map {|a| [a, INITIAL_Q_VALUE]}.to_h if @@q_table[hash_value].nil?
      # update with discount and learning rate, unless it is the final outcome, then use its value straight up
      if last_entry
        @@q_table[hash_value][action] = max_a
        last_entry = false
      else
        @@q_table[hash_value][action] = (1.0 - learning_rate) * @@q_table[hash_value][action] + learning_rate * discount * max_a
      end
      # get max a of all possible actions for the entry in the table
      max_a = @@q_table[hash_value].sort_by {|k, v| v }.last.last
      @@logger.info "max(a): #{max_a}, table: #{@@q_table[hash_value]}"
    end
  end

  def self.reset
    @@q_table = {}
    @@log = []
  end

  def self.q_table
    return @@q_table
  end

  def self.log
    @@log
  end

  def self.set_log(log)
    @@log = log
  end

  def self.enable_random_mode
    @@random_mode = true
  end

  def self.disable_random_mode
    @@random_mode = false
  end

  private
  # calculate a unique key for the cache that represents the game state
  def self.hash_value(attacker, defender)
    d = attacker
    result = "#{d.name} #{d.current_health} #{d.level} "
    d.abilities.each {|a| result << "#{a.class.name} #{a.current_cooldown} #{a.current_delay} " }
    d.modifiers.each {|m| result << "#{m.class.name} #{m.current_turns} #{m.current_attacks} " }
    d = defender
    result << "#{d.name} #{d.current_health} #{d.level} "
    d.abilities.each {|a| result << "#{a.class.name} #{a.current_cooldown} #{a.current_delay} " }
    d.modifiers.each {|m| result << "#{m.class.name} #{m.current_turns} #{m.current_attacks} " }
    result
  end

end
