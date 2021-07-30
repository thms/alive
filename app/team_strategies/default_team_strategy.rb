# For testing always pick the first availabe dinosaur and the first avaialble ability
class DefaultTeamStrategy < TeamStrategy

  # Pick first available dinosaur that is not the current or most recent one
  def self.next_dinosaur(team1, team2)
    target_dinosaur = (team1.available_dinosaurs - [team1.current_dinosaur, team1.recent_dinosaur]).first
    target_ability = target_dinosaur.available_abilities.first
    team1.swap(target_dinosaur, target_ability)
  end

  # pick first available ability for the current dinosaur
  # if no current dinosaur, pick one first
  def self.next_move(team1, team2)
    if team1.current_dinosaur.nil? || team1.current_dinosaur.current_health == 0
      result = next_dinosaur(team1, team2)
      return result[:ability]
    elsif should_swap?(team1, team2)
      result = next_dinosaur(team1, team2)
      return result[:ability]
    else
      return team1.current_dinosaur.available_abilities.first
    end
  end

  # Team should swap if other dino is likely to kill this one
  # this could be much more refined, with expected damage, etc
  def self.should_swap?(team1, team2)
    team1.current_dinosaur.current_health <= team2.current_dinosaur.damage rescue false
  end
end
