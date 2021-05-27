# takes current state as input to a simulation
# calculates all possible futures
# rolls up wins an losses to decide what is the next best move
# needs access to both dinosaurs
class MinMaxStrategy

  # Convention: attacker is the one trying to figure out the next move
  def self.next_move(a, d)
    attacker = deep_clone(a)
    defender = deep_clone(d)
    if attacker.name == defender.name
      attacker.name += '-1'
      defender.name += '-2'
    end
    attacker.color = '#03a9f4'
    defender.color = '#03f4a9'
    simulation = Simulation.new(attacker, defender)
    result = simulation.execute
    # create pruned version of the graph, to make this faster
    simulation.prune(result)


    # Each child is a possible action to take
    # need to look two levels deep, due to priority abilities, etc.
    # So it provides the stats for both dinos, allowing to also guess at what the other should do.
    # TODO: Evaluate these according to the min-max algorithm, rather than just the sum of wins and losses
    # so that we always make the best possible outcome come true
    # https://medium.com/@carsten.friedrich/part-2-the-min-max-algorithm-ae1489509660
    wins_and_losses = {}
    result.children.each do |child|
      w_a_l = simulation.calc_wins_and_losses(child)
      ability_name = child.name.split(' ').first
      begin
        wins_and_losses[ability_name].deep_merge!(w_a_l) {|key, v1, v2| v1 + v2}
      rescue
        wins_and_losses[ability_name] = w_a_l
      end
      # second level down so capture for both what is most likely to be the bet / worst move
      child.children.each do |grandchild|
        w_a_l = simulation.calc_wins_and_losses(grandchild)
        ability_name = grandchild.name.split(' ').first
        begin
          wins_and_losses[ability_name].deep_merge!(w_a_l) {|key, v1, v2| v1 + v2}
        rescue
          wins_and_losses[ability_name] = w_a_l
        end
      end
    end
    # calculate the ratios for both dinosaurs
    # to get something that looks like: {"Velociraptor::Strike" => 0.0, "Velociraptor::HighPounce" => 1.0,
    # "Thoradolosaur::InstantCharge" => 0.0, "Thoradolosaur::FierceImpact" => 1.0}
    stats = wins_and_losses.map {|k,v|
      name = k.to_s.split('::').first # what about stunned nodes
      ratio = v[name][:wins].to_f / (v[name][:wins] + v[name][:losses]).to_f
      [k, ratio]
    }.to_h
    # split by attacker and defender
    sorted_stats = {}
    stats.each do |k,v|
      dinosaur_name = k.split('::').first
      if sorted_stats[dinosaur_name].nil?
        sorted_stats[dinosaur_name] = {k => v}
      else
        sorted_stats[dinosaur_name].merge! ({k => v})
      end
    end
    # At this point we have data like this
    # {"Velociraptor"=>{"Velociraptor::Strike"=>0.0, "Velociraptor::HighPounce"=>1.0}, "Thoradolosaur"=>{"Thoradolosaur::FierceStrike"=>0.5, "Thoradolosaur::FierceImpact"=>0.5}}
    # so we can see what the other should be picking as well.
    # we may get here with nothing for the attacker to choose, i.e. the hash has no move. This happens when the attacker looses
    # in that case we need to pick a random available abillity, later on this would be a good signal to swap in a 4 on 4
    begin
      klass = sorted_stats[attacker.name].sort_by {|k,v| v}.last.first.split('::').last
      puts "class: #{klass}"
      if klass == 'stunned'
        # pick something that is available for the next round
        return a.available_abilities.first
      else
        return a.available_abilities.find {|ability| ability.class.name == klass}
      end
    rescue
      puts 'picking random'
      # need to return the ability of the original attacker that was passed to get the cooldown and delay right.
      return a.available_abilities.sample
    end
  end

  private
  def self.deep_clone(object)
    Marshal.load(Marshal.dump(object))
  end

end
