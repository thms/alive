class RevengeDistractingImpact < Ability

  self.is_implemented = true
  self.cooldown = 1
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 1.5
  self.bypass = []

  def update_defender(attacker, defender)
    defender.add_modifier(Modifiers::Distraction.new(50, 2, 4))
  end

  def damage_defender(attacker, defender)
    self.damage_multiplier = 2.0 if attacker.is_revenge
    super
  end

end
