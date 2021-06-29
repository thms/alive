# Does nothing, used when swapping is denied due to swap prevention or there being not other dinosaur to swap to
# Consequence is that the dino looses its turn
class SwapFailed < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 0
  self.bypass = []

end
