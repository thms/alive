require 'logger'
require 'ruby-fann'
# model the TQ function across a wide range of dinosaurs
# initial version: single dinsoaur only, so we only need a few inputs and  outputs, rather than utputs for 250 abiltities

class NNStrategy

  DISCOUNT = 0.95
  LEARNING_RATE = 0.1
  EPSILON = 0.05

  @@value = nil
  @@action_log = []
  @@state_log = []
  @@q_values_log = []
  @@next_q_max_log = []
  @@log = []
  @@games_played = 0
  @@logger = Logger.new(STDOUT)
  @@logger.level = :info

  def self.reset_logs
    @@action_log = []
    @@state_log = []
    @@q_values_log = []
    @@next_q_max_log = []
  end

  def self.reset
    @@fann = RubyFann::Shortcut.new(:num_inputs=>28*2, :hidden_neurons=>[28*2*8], :num_outputs=>4)
    @@fann.set_learning_rate(0.1) # default value is 0.7
    @@fann.set_training_algorithm(:incremental)
    @@fann.set_activation_function_hidden(:linear)
    @@games_played = 0
  end

  def self.next_move(attacker, defender)
    # store attacker's value for later learning
    @@value = attacker.value
    # get NN inputs
    inputs = state_to_nn_inputs(attacker, defender)
    # get q values
    q_values = @@fann.run(inputs)
    probabilities = softmax(q_values, 1.0)
    @@logger.info "before: #{q_values}"
    # reject all moves that are not available
    probabilities.each.with_index do |v,i|
      # attackers may have two - four abilities (plus the swappy things) so we need to accomodate for that
      if attacker.abilities[i] && !(attacker.abilities[i].current_delay <= 0 &&  attacker.abilities[i].current_cooldown == 0)
        probabilities[i] = 0
      end
      if attacker.abilities[i].nil?
        probabilities[i] = 0
      end
    end
    if rand < EPSILON
      # pick a random ability to do a broad learning in initial training
      index = probabilities.map.with_index {|v, i| v > 0 ? i : nil}.compact.sample
    else
      # pick move with highest value that is possible from the moves that are possible
      highest_value = probabilities.max
      # TODO: turn into using probability band
      index = probabilities.map.with_index {|v, i| highest_value == v ? i : nil}.compact.sample
    end
    ability = attacker.abilities[index]


    # Log data for training at the end of the game
    @@next_q_max_log << q_values[index].clone unless @@action_log.empty?
    @@state_log << inputs.clone
    @@q_values_log << q_values.clone
    @@action_log << index.clone
    return ability
  end

  def self.learn(outcome)
    #return if @@action_log.empty?
    @@games_played += 1
    # push the final reward onto the nextmax log from the point of view of the player
    @@next_q_max_log << (@@value * outcome + 1.0)/2.0
    @@log << @@next_q_max_log
    @@log << ['--']
    index = @@action_log.size - 1
    while index >= 0
      inputs = @@state_log[index]
      outputs = @@q_values_log[index]
      # replace the q value of the move made with the discounted observation
      outputs[@@action_log[index]] = DISCOUNT * @@next_q_max_log[index]
      # do one training step
      @@fann.train(inputs, outputs)
      index -= 1
    end
    # and finally reset the logs after one round of learning (so after each game)
    reset_logs
  end

  # Define the inputs for the nueral network for one dinosaur
  # resistances, level, speed, active modifiers, active
  # generates 26 elements
  def self.dinosaur_to_inputs(dinosaur)
    inputs = []
    inputs.push dinosaur.level / 30.0
    inputs.push dinosaur.value
    dinosaur.resistances.each do |resistance|
      inputs.push resistance / 100.0
    end
    # abilities
    dinosaur.abilities.each do |ability|
      inputs.push ability.current_delay
      inputs.push ability.current_cooldown
    end
    # fill up the empty slots if the dino has less than four abilities
    (4 - dinosaur.abilities.count).times do
      inputs.push 0
      inputs.push 0
    end
    # modifiers
    # current parameters (maybe that is enough, don't need the modifiers?)
    # how to normalize?
    dinosaur.current_attributes.each do |k,v|
      inputs.push v
    end
    inputs.push dinosaur.current_health / 10000.0
    inputs.push dinosaur.current_speed / 200.0
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
    {games: @@games_played}
  end

  def self.save
    state = Marshal.dump({games_played: @@games_played})
    File.open("#{Rails.root}/tmp/n_n_strategy.state", "wb") do |file|
      file.write state
    end
    # safe network separately, library does not support IO streams
    @@fann.save("#{Rails.root}/tmp/n_n_strategy_network.net")
  end

  def self.load
    state = Marshal.load(File.binread("#{Rails.root}/tmp/n_n_strategy.state"))
    @@games_played = state[:games_played]
    @@fann = RubyFann::Shortcut.new(filename: "#{Rails.root}/tmp/n_n_strategy_network.net")
  end


end
