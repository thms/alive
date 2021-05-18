# Picks from the avaialbe moves one that deals the highest damage
# without taking the defender into account yet
class HighestDamageStrategy

  def self.next_move(attacker, defender)
    # select ability by higest damage
    attacker.available_abilities.sort_by {| ability| ability.damage_multiplier}.last
  end

end
