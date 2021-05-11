# TODO:
class ArmorPiercingRampage < Ability

  self.is_implemented = true
  self.initial_cooldown = 0
  self.initial_delay = 0
  self.is_priority = false
  self.damage_multiplier = 2
  self.bypass = [:armor]

end
