class RendingTakedown < Ability

  self.is_implemented = true
  self.initial_cooldown = 1
  self.initial_delay = 1
  self.is_priority = false
  self.damage_multiplier = 0.6
  self.bypass = [:armor]
  self.is_rending_attack = true

  def update_defender(attacker, defender)
    defender.destroy_shields
  end
end
