# Does nothing, used when swapping in and the dino has no swap-in ability
class NoOp < Ability

  self.is_implemented = true
  self.initial_cooldown = 0
  self.initial_delay = 0
  self.is_priority = true
  self.damage_multiplier = 0
  self.bypass = []

end
