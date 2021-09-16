require 'logger'
require 'ruby-fann'
# model the TQ function across a wide range of dinosaurs
# initial version: single dinsoaur only, so we only need a few inputs and  outputs, rather than utputs for 250 abiltities

class NNStrategy

  DISCOUNT = 0.95
  LEARNING_RATE = 0.01
  EPSILON_DECAY = 100
  EPSILON = 0.2
  class_attribute :max_a_s
  class_attribute :value
  class_attribute :action_log
  class_attribute :state_log
  class_attribute :q_values_log
  class_attribute :next_q_max_log
  class_attribute :games_played
  class_attribute :fann
  @@value = nil
  @@action_log = []
  @@state_log = []
  @@q_values_log = []
  @@next_q_max_log = []
  @@max_a_s = {}
  @@log = []
  @@games_played = 0
  @@logger = Logger.new(STDOUT)
  @@logger.level = :warn
  @@use_experience_replay = false
  @@experience_replay_log = []
  @@train_on_softmax = false
  @@learning_mode = false


  # reset the logs used during training after one episode
  def self.reset_logs
    @@action_log = []
    @@state_log = []
    @@q_values_log = []
    @@next_q_max_log = []
  end

  def self.reset(params)
    @@fann = RubyFann::Standard.new(:num_inputs=>28*2, :hidden_neurons=>[32*2*8], :num_outputs=>params[:outputs])
    @@fann.set_learning_rate(0.01) # default value is 0.7
    @@fann.set_training_algorithm(:incremental)
    @@fann.set_activation_function_hidden(:relu)
    @@fann.set_activation_function_output(:relu)
    #@@fann.randomize_weights(0.003,0.003)
    @@games_played = 0
    @@epsilon = EPSILON
    @@max_a_s = {}
    reset_logs
  end

  def self.next_move(attacker, defender)
    available_abilities_index = attacker.abilities.map(&:is_available?)
    # store attacker's value for later learning
    @@value = attacker.value
    # get NN inputs
    inputs = state_to_nn_inputs(attacker, defender)
    # get q values
    q_values = @@fann.run(inputs)
    probabilities = softmax(q_values, 0.8)
    @@logger.info "q_values: #{q_values}"
    @@logger.info "probs: #{probabilities.map {|p| (100 * p).round(2)}}"

    # squash q_values to zero for unavailalble moves
    q_values_squashed = available_abilities_index.map.with_index {|v, i| v == true ? q_values[i] : 0.0 }
    # select a move either randomly or based on the strategy
    if @@learning_mode && rand < EPSILON # ** @@games_played
      # pick a random available ability to do a broad learning in initial training
      #index = q_values.map.with_index {|v, i| v > -100 ? i : nil}.compact.sample
      index = available_abilities_index.map.with_index {|v, i| v == true ? i : nil}.compact.sample
    else
      # pick move with highest value from the moves that are possible
      highest_value = available_abilities_index.map.with_index {|v, i| v == true ? q_values[i] : nil}.compact.max
      # TODO: turn into using probability band
      index = q_values.map.with_index {|v, i| highest_value == v ? i : nil}.compact.sample
    end
    ability = attacker.abilities[index]


    # Log data for training at the end of the game
    # train on the softmax values rather than the q_values, restore first to make sure e don't learn what things are not available and give them a bad name
    if @@train_on_softmax
      training = probabilities
    else
      training = q_values_squashed
    end
    @@next_q_max_log << training[index].deep_dup unless @@action_log.empty?
    @@state_log << inputs.deep_dup
    @@q_values_log << training.deep_dup
    @@action_log << index.deep_dup
    return ability
  end

  def self.learn(outcome, attacker_value = 1.0)
    return if @@action_log.empty?
    @@games_played += 1

    # average the final outcomes in a specific state & action combination
    # in order to account for probabilistic nature of outcomes, i.e. critical chance, etc.
    # these rewards should converge to the avearge between winning and loosing
    hash_value = hash_value([@@state_log.last, @@action_log.last].flatten)
    if @@max_a_s[hash_value].nil?
      @@max_a_s[hash_value] = [(@@value * outcome + 1.0)/2.0]
    else
      @@max_a_s[hash_value].push (@@value * outcome + 1.0)/2.0
    end
    max_a = @@max_a_s[hash_value].sum(0.0) / @@max_a_s[hash_value].size
    # push the final reward onto the nextmax log from the point of view of the player
    @@next_q_max_log << max_a

    @@log << @@next_q_max_log
    @@log << ['--']
    index = @@action_log.size - 1
    @@logger.info @@action_log
    @@logger.info @@next_q_max_log
    @@logger.info @@q_values_log
    last_entry = true
    while index >= 0
      inputs = @@state_log[index]
      outputs = @@q_values_log[index]
      if last_entry
        # for the last entry, do not discount
        last_entry = false
        outputs[@@action_log[index]] = @@next_q_max_log[index]
      else
        # replace the q value of the move made with the discounted observation
        outputs[@@action_log[index]] = DISCOUNT * @@next_q_max_log[index]
      end
      # do one training step
      @@fann.train(inputs, outputs)
      index -= 1
    end

    # append logs to experience replay log
    @@experience_replay_log << {next_q_max: @@next_q_max_log, state: @@state_log, q_values: @@q_values_log, actions: @@action_log}
    @@experience_replay_log.shift if @@experience_replay_log.size > 100
    # reset the logs after one round of learning (so after each game)
    reset_logs
    # replay experience every so often
    experience_replay if @@games_played.modulo(100) == 0 && @@use_experience_replay
    @@logger.info "============"
  end

  def self.experience_replay
    @@experience_replay_log.sample(100).each do |entry|
      action_log = entry[:actions]
      next_q_max_log = entry[:next_q_max]
      state_log = entry[:state]
      q_values_log = entry[:q_values]
      index = action_log.size - 1
      last_entry = true
      while index >= 0
        inputs = state_log[index]
        outputs = q_values_log[index]
        if last_entry
          last_entry = false
          outputs[action_log[index]] = next_q_max_log[index]
        else
          # replace the q value of the move made with the discounted observation
          outputs[action_log[index]] = DISCOUNT * next_q_max_log[index]
        end
        # do one training step
        @@fann.train(inputs, outputs)
        index -= 1
      end
    end
  end

  def self.dinosaur_to_inputs(dinosaur)
    dinosaur_to_inputs_long(dinosaur)
  end
  # Define the inputs for the nueral network for one dinosaur
  # resistances, level, speed, active modifiers, active
  # generates 26 elements
  def self.dinosaur_to_inputs_short(dinosaur)
    inputs = []
    inputs.push (dinosaur.value + 1.0)/2.0
    inputs.push dinosaur.current_speed / 200.0
    inputs.push dinosaur.current_health / 10000.0
    inputs.push dinosaur.damage / 10000.0
    inputs.push dinosaur.is_stunned ? 1.0 : 0.0
    inputs
  end

  def self.dinosaur_to_inputs_long(dinosaur)
    inputs = []
    inputs.push dinosaur.level / 30.0
    inputs.push (dinosaur.value + 1.0)/2.0
    inputs.push dinosaur.current_speed / 200.0
    inputs.push dinosaur.current_health / 10000.0
    inputs.push dinosaur.damage / 10000.0
    inputs.push dinosaur.critical_chance / 100.0
    inputs.push dinosaur.armor / 100.0
    # nine resistances
    dinosaur.resistances.each do |resistance|
      inputs.push (100.0 - resistance) / 100.0
    end
    # up to four abilities
    dinosaur.abilities.each do |ability|
      inputs.push ability.is_available? ? 1.0 : 0.0
      #inputs.push ability.current_cooldown == 0 ? 1 : 0
      end
    # fill up the empty slots if the dino has less than four abilities
    (4 - dinosaur.abilities.count).times do
      inputs.push 0
    end
    # modifiers

    # current parameters (maybe that is enough, don't need the modifiers?)
    dinosaur.current_attributes.each do |k,v|
      begin
        inputs.push v / 100.0
      rescue
        inputs.push v ? 1.0 : 0.0
      end
    end

    inputs.push dinosaur.is_stunned ? 1.0 : 0.0
    inputs
  end

  def self.state_to_nn_inputs(attacker, defender)
    [dinosaur_to_inputs(attacker), dinosaur_to_inputs(defender)].flatten
  end

  # normalizes the output q-values so they can be used as probabilities
  # temperature: 0..infinity, for high temperatures nearly all probabilities are the same, for low 0+eplsilon, the
  # probability of the highest value approaches 1
  # https://en.wikipedia.org/wiki/Softmax_function
  # Use higher temperature steer how exploratory the player will be by picking from a set of possible actions within a band of probability
  def self.softmax(values, temperature = 1.0)
    denominator = values.collect {|v| Math.exp(v / temperature)}.reduce(:+)
    values.collect {|v| Math.exp(v/temperature) / denominator}
  end

  def self.stats
    {games: @@games_played, epsilon: EPSILON ** @@games_played}
    {games: @@games_played, epsilon: EPSILON}
  end

  def self.max_a_s
    @@max_a_s
  end

  def self.fann
    @@fann
  end

  def self.enable_learning_mode
    @@learning_mode = true
  end

  def self.disable_learning_mode
    @@learning_mode = false
  end

  def self.save
    state = Marshal.dump({games_played: @@games_played, max_a_s: @@max_a_s})
    File.open("#{Rails.root}/tmp/n_n_strategy.state", "wb") do |file|
      file.write state
    end
    # safe network separately, library does not support IO streams
    @@fann.save("#{Rails.root}/tmp/n_n_strategy_network.net")
  end

  def self.load
    state = Marshal.load(File.binread("#{Rails.root}/tmp/n_n_strategy.state"))
    @@games_played = state[:games_played]
    @@max_a_s = state[:max_a_s]
    @@fann = RubyFann::Standard.new(filename: "#{Rails.root}/tmp/n_n_strategy_network.net")
    reset_logs
    self
  end

  # calculate a unique key for the cache that represents the game state
  def self.hash_value(inputs)
    Digest::MD5.hexdigest(inputs.to_s)
  end


end
