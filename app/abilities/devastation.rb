class Devastation < Ability

  self.is_implemented = true
  self.cooldown = 1
  self.delay = 2
  self.is_priority = false
  self.damage_multiplier = 3
  self.bypass = [:dodge, :cloak]

  def update_attacker(attacker)
    attacker.add_modifier(Modifiers::Taunt.new(1))
  end
end
