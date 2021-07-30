require 'logger'
# Tabular Q Function strategy
# Learning over the course of a number of games what works best in a gven state of the game
# Inputs to learning: state == attacker, defender (teams)
# outputs: value for each of the dinosaurs abilties (max of four per dinosaur) and wheter it is best to swap
# Q_Table stores a hash of the availble abilities to the q value per dinosaur: {Indoraptor::CunningStrike" => 0.3, "Thoradolosaur::FierceImpact" => 0.6}}
class TQTeamStrategy < TeamStrategy

  INITIAL_Q_VALUE = 0.2
  EPSILON = 0.05 # eplison greedy strategy: pick suboptimal move in 5% of cases
  @@q_table = {} # state to ability + dinosaur mapping
  @@q_table_swap = {} # state to swapp in new dinosaur mapping
  @@max_a_s = {} # stores all outcomes for a given final move in a state to allow averaging
  @@log = {1.0 => [], -1.0 => []}
  @@random_mode = false
  @@swap_penalty = 0.2 # penalty on swapping moves, no adjustment would be 1.0, use to make the game less swappy
  @@games_played = 0
  @@logger = Logger.new(STDOUT)
  @@logger.level = :warn


  # pick the next dinosaur, either at the start of the game or when a swap is needed
  # TODO: need to pick these also depending on the q table
  # Not being used
  def self.next_dinosaur(attacker, defender)
    target_dinosaur = (attacker.available_dinosaurs - [attacker.current_dinosaur, attacker.recent_dinosaur]).sample
    attacker.swap(target_dinosaur)
  end

  def self.should_swap?(attacker, defender)
    # must swap if dead
    return true if attacker.current_dinosaur.current_health <= 0
    # ask the q table if it should swap
    available_dinosaur_names = attacker.available_dinosaurs.map(&:name)
    hash = TeamMatch.hash_value(attacker, defender)
    dinosaurs = @@q_table_swap
    # if empty, initialize and pick a random dinosaur
    if dinosaurs.nil?
      @@q_table_swap[hash] = available_dinosaur_names.map {|d| [d, INITIAL_Q_VALUE]}.to_h
      dinosaur_name = available_dinosaur_names.sample
    elsif rand < EPSILON
      dinosaur_name = available_dinosaur_names.sample
    else
      highest_value = dinosaurs.sort_by {|k, v| v}.last.last
      dinosaur_name = dinosaur.map {|k, v| highest_value == v ? k : nil}.compact.sample
    end
    # return true if the new selection is a swap, false otherwise
    # TODO: should probably say which dinosaur to use and if this is a swap
    dinosaur_name != attacker.current_dinosaur.name
  end

  def self.next_move(attacker, defender)

    available_ability_names = []
    attacker.available_dinosaurs.each do |dinosaur|
      dinosaur.available_abilities.each do |ability|
         available_ability_names.push "#{dinosaur.name}::#{ability.class.name}"
      end
    end
    hash = TeamMatch.hash_value(attacker, defender)
    # abilities according to the Q table
    abilities = @@q_table[hash].clone
    # if empty, initialize and pick a random available ability from the current dinosaur or swap randomly
    if abilities.nil?
      @@logger.info "No q-table entry found"
      @@q_table[hash] = available_ability_names.map {|a| [a, INITIAL_Q_VALUE]}.to_h
      target_dinosaur = attacker.available_dinosaurs.sample
      ability = "#{target_dinosaur.name}::#{target_dinosaur.available_abilities.sample.class.name}"
    elsif @@random_mode || rand < EPSILON
      @@logger.info "Picking random ability"
      # pick a random dinosaur and ability to do a broad learning in initial training
      ability = available_ability_names.sample
    else
      # adjust values for swapping moves to discourage swapping - current learning leads to excessive swapping
      abilities.each do |k, v|
        abilities[k] = (@@swap_penalty * v) unless (attacker.current_dinosaur.nil? || k.include?(attacker.current_dinosaur.name))
      end
      # What is the highest value
      highest_value = abilities.sort_by {|k, v| v}.last.last
      # find all moves that have the highest value and pick one at random
      ability = abilities.map {|k, v| highest_value == v ? k : nil}.compact.sample
    end
    @@log[attacker.value].push [hash, available_ability_names, attacker.value, ability]

    # At this stage we have something like "Indoraptor::CleansingStrike", and need to test if we can / have to swap dinosaurs
    dinosaur_name, ability_name = ability.split('::')
    if !attacker.current_dinosaur.nil? && dinosaur_name == attacker.current_dinosaur.name
      # no need to swap, current dinosaur is the best choice
      return attacker.current_dinosaur.abilities.select {|a| a.class.name == ability_name}.first
    else
      # need to swap, other dinosaur is better, if that fails the current stays and does nothing
      target_dinosaur = attacker.dinosaurs.select {|d| d.name == dinosaur_name}.first
      target_ability = target_dinosaur.abilities.select {|a| a.class.name == ability_name}.first
      result = attacker.try_to_swap(target_dinosaur, target_ability)
      return result[:ability]
    end
  end

  def self.learn(outcome, attacker_value)
    return if @@log[attacker_value].empty?
    @@games_played += 1
    update_q_table(outcome, attacker_value)
  end
  # log is an array of shape: [[hash, attacker, defender before action, player value, action]], outcome is 0.0, 0.5 or 1.0
  # distribute reward backwards from the last move with discount and apply learning
  # action is "FierceStrike", etc
  # player value = 1.0 or -1.0
  # log does not include the final state of the game, since it is not needed for training
  def self.update_q_table(outcome, attacker_value)
    learning_rate = 0.01
    discount = 0.95
    # calcuate average of outcomes for the final move to account for probabilities
    hash_value = @@log[attacker_value].last[0]
    if @@max_a_s[hash_value].nil?
      @@max_a_s[hash_value] = [(1.0 + attacker_value * outcome)/2.0]
    else
      @@max_a_s[hash_value].push (1.0 + attacker_value * outcome)/2.0
    end
    max_a = @@max_a_s[hash_value].sum(0.0) / @@max_a_s[hash_value].size
    last_entry = true
    while entry = @@log[attacker_value].pop
      hash_value = entry[0]
      available_ability_names = entry[1]
      action = entry[3]
      # initialise q_table if not yet done
      @@q_table[hash_value] = available_ability_names.map {|a| [a, INITIAL_Q_VALUE]}.to_h if @@q_table[hash_value].nil?
      # update with discount and learning rate, unless it is the final outcome, then use its value straight up
      if last_entry
        # due to the stochastic nature of these outcomes, we cannot simply use the last outcome for this given
        # state, but need to average across them all. (I.e. if a move with critical leads to a win and with crit to a loss)
        @@q_table[hash_value][action] = max_a
        last_entry = false
      else
        @@q_table[hash_value][action] = (1.0 - learning_rate) * @@q_table[hash_value][action] + learning_rate * discount * max_a
      end
      # get max a of all possible actions for the entry in the table
      max_a = @@q_table[hash_value].sort_by {|k, v| v }.last.last
      # @@logger.info "max(a): #{max_a}, table: #{@@q_table[hash_value]}"
    end
  end

  def self.reset
    @@q_table = {}
    @@log = {1.0 => [], -1.0 => []}
    @@games_played = 0
    @@max_a_s = {}
  end

  def self.q_table
    return @@q_table
  end

  def self.log
    @@log
  end

  def self.games_played
    @@games_played
  end

  def self.max_a_s
    @@max_a_s
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

  def self.stats
    {games: @@games_played, size: @@q_table.size, max_a_s: @@max_a_s.size}
  end

  def self.save
    state = Marshal.dump({q_table: @@q_table, games_played: @@games_played, max_a_s: @@max_a_s})
    File.open("#{Rails.root}/tmp/t_q_team_strategy.state", "wb") do |file|
      file.write state
    end
  end

  def self.load
    state = Marshal.load(File.binread("#{Rails.root}/tmp/t_q_team_strategy.state"))
    @@q_table = state[:q_table]
    @@games_played = state[:games_played]
    @@max_a_s = state[:max_a_s]
  end


end
