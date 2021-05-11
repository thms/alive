# Rampage
# Deal 2x damage
class Rampage < Ability

  self.is_implemented = true
  self.initial_cooldown = 1
  self.initial_delay = 1
  self.is_priority = false
  self.damage_multiplier = 2
  self.bypass = []

end
