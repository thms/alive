# Simple strike, just deal attackers to defnder, no other effects
class Strike < Ability

  self.initial_cooldown = 0
  self.initial_delay = 0
  self.is_priority = false

  def damage_defender(attacker, defender)
    defender.current_health -= attacker.damage
  end

end
