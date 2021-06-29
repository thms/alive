# Nullifying rampage
# Deal damage 2x
# Remove all positive effect on the defender
class NullifyingRampage < Ability

  self.is_implemented = true
  self.cooldown = 2
  self.delay = 1
  self.is_priority = false
  self.damage_multiplier = 2
  self.bypass = []

  def update_defender(attacker, defender)
    defender.nullify
  end

end
