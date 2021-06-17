# TODO: implement swap out
class RampageAndRun < Ability

  self.is_implemented = true
  self.initial_cooldown = 1
  self.initial_delay = 1
  self.is_priority = false
  self.is_swap_out = true
  self.damage_multiplier = 2
  self.bypass = []

end
