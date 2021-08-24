class MinorRendingAttack < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 0.34
  self.bypass = [:armor]
  self.is_rending_attack = true

  def update_defender(defender)
    defender.destroy_shields
  end
end
