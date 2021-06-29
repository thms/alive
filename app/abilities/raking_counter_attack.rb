class RakingCounterAttack < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = []
  self.is_counter = true

  def update_defender(attacker, defender)
    defender.remove_cloak
    defender.remove_dodge
  end

end
