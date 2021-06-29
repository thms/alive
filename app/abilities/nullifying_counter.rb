class NullifyingCounter < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.is_priority = true
  self.damage_multiplier = 0
  self.bypass = []

  def update_defender(attacker, defender)
    defender.nullify
  end

end
