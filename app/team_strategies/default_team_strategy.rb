# For testing always pick the first availabe dinosaur and the first avaialble ability
class DefaultTeamStrategy < TeamStrategy

  # Pick first available dinosaur that is not the current or most recent one
  # and has sufficient health
  # if none have sufficient health, don't swap
  def self.next_dinosaur(team1, team2)
    if team1.current_dinosaur.nil?
      target_dinosaur = (team1.available_dinosaurs - [team1.current_dinosaur, team1.recent_dinosaur]).first
      target_ability = target_dinosaur.available_abilities.first
      return team1.try_to_swap(target_dinosaur, target_ability)
    elsif team1.dinosaurs.none? {|d| d.current_health > team2.current_dinosaur.damage} && team1.current_dinosaur.current_health > 0
      return {ability: team1.current_dinosaur.available_abilities.first}
    else
      low_health_dinosaurs = team1.dinosaurs.select {|d| d.current_health <= team2.current_dinosaur.damage}
      target_dinosaur = (team1.available_dinosaurs - low_health_dinosaurs - [team1.current_dinosaur, team1.recent_dinosaur]).first
      target_ability = target_dinosaur.available_abilities.first
      return team1.try_to_swap(target_dinosaur, target_ability)
    end
  rescue
    target_dinosaur = (team1.available_dinosaurs - [team1.current_dinosaur, team1.recent_dinosaur]).first
    target_ability = target_dinosaur.available_abilities.first
    return team1.try_to_swap(target_dinosaur, target_ability)
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

  # Team should swap if other dino is likely to kill this one, and there
  # is another with sufficient health
  # this could be much more refined, with expected damage, etc
  def self.should_swap?(team1, team2)
    if team1.dinosaurs.any? {|d| d.current_health > team1.current_dinosaur.damage} && team1.current_dinosaur.current_health <= team2.current_dinosaur.damage
      true
    else
      false
    end
  rescue
    false
  end
end
