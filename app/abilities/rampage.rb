# Rampage
# Deal 2x damage
class Rampage < Ability

  self.initial_cooldown = 1
  self.initial_delay = 1

  def damage_defender(attacker, defender)
    defender.current_health -= 2 * attacker.damage
  end

end
