class EvasiveStrike < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = []

  def update_attacker(attacker)
    attacker.add_modifier(Modifiers::Dodge.new(75, 1, 1))
  end

end
