# Picks from the avaialbe moves one that deals the highest damage
# without taking the defender into account yet
class HighestDamageStrategy

  def self.next_move(available_abilities)
    # select ability by higest damage
    available_abilities.sort_by {| ability| ability.damage_multiplier}.last
  end

end
