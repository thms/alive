class SwapInNullification < Ability

  self.is_implemented = true
  self.initial_cooldown = 0
  self.initial_delay = 0
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = []

  def update_attacker(attacker, defender)
    attacker.add_modifier(Modifiers::PreventSwap.new(1, 'self'))
  end

  def update_defender(attacker, defender)
    defender.nullify
  end

end
