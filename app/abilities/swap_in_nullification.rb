class SwapInNullification < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = []

  def update_attacker(attacker)
    attacker.add_modifier(Modifiers::PreventSwap.new(1, 'self'))
  end

  def update_defender(defender)
    defender.nullify
  end

end
