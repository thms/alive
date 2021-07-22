# Does nothing, used when the dino is stunned
# When stunned, there is still countdowns of distraction, attack and critical modification
# but no countdown of attack ticks
class IsStunned < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 0
  self.bypass = []

  def update_attacker(attacker, defender)
    attacker.is_stunned = false
  end

end
