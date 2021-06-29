class GroupSuperiority < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = [:dodge, :cloak]

  def update_attacker(attacker, defender)
    attacker.cleanse(:all)
  end

  def update_defender(attacker, defender)
    defender.add_modifier(Modifiers::DecreaseSpeed.new(50, 1))
  end

end
