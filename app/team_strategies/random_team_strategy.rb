# Really for testing only, pick a random available ability
class RandomTeamStrategy < TeamStrategy

  # Pick a random available dinosaur that is not the current or most recent one and attempt to swap
  def self.next_dinosaur(team1, team2)
    target_dinosaur = (team1.available_dinosaurs - [team1.current_dinosaur]).sample
    target_ability = target_dinosaur.available_abilities.sample
    team1.try_to_swap(target_dinosaur, target_ability)
  end

  # pick a new dinosaur at random and a move, or just a move for the current dinosaur
  def self.next_move(team1, team2)
    if team1.current_dinosaur.nil? || team1.current_dinosaur.current_health == 0
      # if there is no current dinosaur, or the current has died pick a new one
      result = next_dinosaur(team1, team2)
      return result[:ability]
    elsif should_swap?(team1, team2) && team1.can_swap?
      result = next_dinosaur(team1, team2)
      return result[:ability]
    else
      # current dinosaur exists and is healthy, so pick a move
      return team1.current_dinosaur.available_abilities.sample
    end
  end

  # Team should swap with 20% probability
  def self.should_swap?(team1, team2)
    rand <= 0.2
  end

  def self.stats
    {}
  end

end
