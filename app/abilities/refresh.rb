class Refresh < Ability

  self.is_implemented = true
  self.cooldown = 2
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 0
  self.bypass = []

  def update_attacker(attacker)
    attacker.cleanse(:all)
    attacker.heal(attacker.damage)
    attacker.add_modifier(Modifiers::IncreaseSpeed.new(10, 2))
  end

end
