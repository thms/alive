# Nullifying rampage
# Deal damage 2x
# Remove all positive effect on the defender
class NullifyingRampage < Ability

  self.initial_cooldown = 2
  self.initial_delay = 1
  self.is_priority = false
  self.damage_multiplier = 2
  self.bypass = []

  def update_defender(attacker, defender)
    defender.nullify
  end

end
