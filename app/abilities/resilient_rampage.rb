class ResilientRampage < Ability

  self.is_implemented = true
  self.cooldown = 1
  self.delay = 1
  self.is_priority = false
  self.damage_multiplier = 2
  self.bypass = []

  def update_attacker(attacker)
    attacker.cleanse(:distraction)
  end

  def update_defender(defender)
    defender.remove_dodge
    defender.remove_cloak
    defender.remove_speed_increase
  end

  def update_defender_after_damage(defender)
    defender.add_modifier(Modifiers::DecreaseSpeed.new(50, 1))
  end

end
