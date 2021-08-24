# Heal
# heal self: 1x own damage
# cleanse all negative effects
class Heal < Ability

  self.is_implemented = true
  self.cooldown = 3
  self.delay = 0
  self.is_priority = true
  self.damage_multiplier = 0
  self.bypass = []

  def update_attacker(attacker)
    attacker.heal(1.5 * attacker.damage)
    attacker.cleanse(:all)
  end

end
