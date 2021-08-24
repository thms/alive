class PreciseShatteringCounter < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = [:armor, :dodge, :cloak]

  def update_defender(defender)
    defender.destroy_shields
  end



end
