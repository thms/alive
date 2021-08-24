class RevengeCloak < Ability

  self.is_implemented = true
  self.cooldown = 3
  self.delay = 0
  self.is_priority = true
  self.damage_multiplier = 0
  self.bypass = []

  def update_attacker(attacker)
    if attacker.is_revenge
      self.cooldown = 1
      attacker.add_modifier(Modifiers::Cloak.new(75, 200, 1, 1))
    else
      attacker.add_modifier(Modifiers::Cloak.new(75, 100, 2, 1))
    end
  end

end
