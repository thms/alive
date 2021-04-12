# Heal
# heal self: 1x own damage
# cleanse all negative effects
class Heal < Ability

  self.initial_cooldown = 0
  self.initial_delay = 0
  self.is_priority = true
  self.damage_multiplier = 0
  self.bypass = []

  def update_attacker(attacker, defender)
    attacker.current_health += [attacker.health - attacker.current_health, attacker.damage].min
    attacker.cleanse(:all)
  end

end
