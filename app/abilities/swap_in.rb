# Does nothing, used when swapping in when the previous dino is still alive and the dino has no swap-in ability
# On swap in, when the previous dino is still alive, the the dino does not get to choose the action
class SwapIn < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.is_priority = true
  self.damage_multiplier = 0
  self.bypass = []

end
