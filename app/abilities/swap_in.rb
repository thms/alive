# Does nothing, used when swapping in and the dino has no swap-in ability
class SwapIn < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.is_priority = true
  self.damage_multiplier = 0
  self.bypass = []

end
