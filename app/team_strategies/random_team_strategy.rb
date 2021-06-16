# Really for testing only, pick a random available ability
class RandomTeamStrategy < TeamStrategy

  # Pick a random available dinosaur that is not the current or most recent one
  def self.next_dinosaur(team1, team2)
    new_dinosaur = (team1.available_dinosaurs - [team1.current_dinosaur, team1.recent_dinosaur]).sample
    team1.swap(new_dinosaur)
  end

  # pick a new dinosaur at random and a move, or just a move for the current dinosaur
  def self.next_move(team1, team2)
    # in 20% swap the dinosaur (which also set one if there is none yet)
    if rand > 0.8
      next_dinosaur(team1, team2)
    end
    # if there is no current dinosaur, pick a new one
    next_dinosaur(team1, team2) if team1.current_dinosaur.nil? || team1.current_dinosaur.current_health <= 0
    return team1.current_dinosaur.available_abilities.sample
  end

end
