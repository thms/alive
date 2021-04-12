# Fierce strike,bypass armor, attack 1x
class FierceStrike < Ability

  self.initial_cooldown = 0
  self.initial_delay = 0
  self.is_priority = false
  self.damage_multiplier = 1.5
  self.bypass = [:armor]

end
