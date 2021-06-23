class SwapInStun < Ability

  self.is_implemented = true
  self.initial_cooldown = 0
  self.initial_delay = 0
  self.is_priority = true
  self.damage_multiplier = 0
  self.bypass = []


  def damage_defender(attacker, defender)
    result = super
    # stun the defender, with 66% probability depending on the resistance of the defender
    defender.is_stunned = rand(100) < (0.66 * (100.0 - defender.resistance(:stun)))
    result
  end

end
