# TODO:
class ArmorPiercingImpact < Ability

  self.is_implemented = true
  self.cooldown = 1
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 1.5
  self.bypass = [:armor]

end
