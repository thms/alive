# Nullifying impact
# Deal damage 1.5x
# Remove all positive effect on the defender
class NullifyingImpact < Ability

  self.is_implemented = true
  self.cooldown = 2
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 1.5
  self.bypass = []

  def update_defender(defender)
    defender.nullify
  end

end
