class DefenseShatteringStrike < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = [:armor]

  def update_defender(attacker, defender)
    defender.destroy_shields
    defender.remove_taunt
  end

end
