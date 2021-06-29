class EvasiveRampage < Ability

  self.is_implemented = true
  self.cooldown = 2
  self.delay = 1
  self.is_priority = false
  self.damage_multiplier = 2
  self.bypass = []

  def update_attacker(attacker, defender)
    attacker.add_modifier(Modifiers::Dodge.new(75, 2, 4))
  end

end
