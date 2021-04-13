# Nullifying strike
# Deal damage 1x
# Remove all positive effect on the defender
class NullifyingStrike < Ability

  self.initial_cooldown = 0
  self.initial_delay = 0
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = []

  def update_defender(attacker, defender)
    defender.nullify
  end

end
