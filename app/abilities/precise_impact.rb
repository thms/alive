# Target lowest HP Precise attack 2x
class PreciseImpact < Ability

  self.is_implemented = true
  self.cooldown = 1
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 1.5
  self.bypass = [:dodge, :cloak]

end
