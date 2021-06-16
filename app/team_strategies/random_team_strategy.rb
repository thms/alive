# Really for testing only, pick a random available ability
class RandomTeamStrategy < TeamStrategy

  # Pick a random available dinosaur that is not the current or most recent one
  def self.next_dinosaur(team1, team2)
    new_dinosaur = (team1.available_dinosaurs - [team1.current_dinosaur, team1.recent_dinosaur]).sample
    team1.swap(new_dinosaur)
  end

  # pick a new dinosaur at random and a move, or just a move for the current dinosaur
  def self.next_move(team1, team2)
    was_healthy = team1.current_dinosaur.current_health > 0 rescue false
    has_swapped = false
    # in 20% swap the dinosaur randomly
    if rand > 0.8 && team1.can_swap?
      next_dinosaur(team1, team2)
      has_swapped = true
    end
    # if there is no current dinosaur, or the current has died pick a new one
    if team1.current_dinosaur.nil? || team1.current_dinosaur.current_health <= 0
      next_dinosaur(team1, team2)
      has_swapped = true
    end

    if has_swapped && was_healthy
      return team1.current_dinosaur.has_swap_in? ? team1.current_dinosaur.abilities_swap_in.first : SwapIn.new
    else
      return team1.current_dinosaur.available_abilities.sample
    end
  end

end
