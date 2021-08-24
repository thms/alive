class EvasiveStance < Ability

  self.is_implemented = true
  self.cooldown = 3
  self.delay = 0
  self.is_priority = true
  self.damage_multiplier = 0
  self.bypass = []

  def update_attacker(attacker)
    attacker.add_modifier(Modifiers::Dodge.new(75, 3, 4))
  end

end
