class FierceImpact < Ability

  self.is_implemented = true
  self.cooldown = 1
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 1.5
  self.bypass = [:armor]

  def update_attacker(attacker)
    attacker.cleanse(:vulnerable)
  end

  def update_defender(defender)
    defender.destroy_shields
    defender.remove_taunt
  end

end
