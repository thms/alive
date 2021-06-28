class SwapInStunningStrike < Ability

  self.is_implemented = true
  self.initial_cooldown = 0
  self.initial_delay = 0
  self.is_priority = true
  self.damage_multiplier = 1
  self.bypass = [:armor]

  def update_attacker(attacker, defender)
    attacker.add_modifier(Modifiers::PreventSwap.new(2, 'self'))
  end

  def damage_defender(attacker, defender)
    result = super
    # 66% chance to stun the defender, with probability depending on the resistance of the defender
    defender.is_stunned = rand(100) < 0.66 * (100 - defender.resistance(:stun))
    result
  end

end
