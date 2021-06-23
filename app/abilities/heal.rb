# Heal
# heal self: 1x own damage
# cleanse all negative effects
class Heal < Ability

  self.is_implemented = true
  self.initial_cooldown = 3
  self.initial_delay = 0
  self.is_priority = true
  self.damage_multiplier = 0
  self.bypass = []

  def update_attacker(attacker, defender)
    attacker.heal(1.5 * attacker.damage)
    attacker.cleanse(:all)
  end

end
