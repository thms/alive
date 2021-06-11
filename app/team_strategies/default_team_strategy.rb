# For testing always pick the first availbe dinosaur and the first avaialble ability
class DefaultTeamStrategy < TeamStrategy

  # Pick first available dinosaur that is not the current or most recent one
  def self.next_dinosaur(team1, team2)
    new_dinosaur = (team1.available_dinosaurs - [team1.current_dinosaur, team1.recent_dinosaur]).first
    team1.swap(new_dinosaur)
    new_dinosaur
  end

  # pick first available ability for the current dinosaur
  # if no current dinosaur, pick one first
  def self.next_move(team1, team2)
    next_dinosaur(team1, team2) if team1.current_dinosaur.nil? || team1.current_dinosaur.current_health <= 0
    return team1.current_dinosaur.available_abilities.first
  end
end
