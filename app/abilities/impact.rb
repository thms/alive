# Target lowest HP
# Damage 1.5x
class Impact < Ability

  self.is_implemented = true
  self.initial_cooldown = 0
  self.initial_delay = 0
  self.is_priority = false
  self.damage_multiplier = 1.5
  self.bypass = []

end
