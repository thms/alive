# TODO:
class ArmorPiercingRampage < Ability

  self.is_implemented = true
  self.cooldown = 1
  self.delay = 1
  self.is_priority = false
  self.damage_multiplier = 2
  self.bypass = [:armor]

end
