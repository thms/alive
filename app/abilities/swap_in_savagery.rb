class SwapInSavagery < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.is_priority = true
  self.damage_multiplier = 0.4
  self.bypass = []
  self.is_rending_attack = true


  def update_attacker(attacker, defender)
    attacker.add_modifier(Modifiers::PreventSwap.new(2, 'self'))
  end

end
