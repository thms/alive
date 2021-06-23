class Immobilize < Ability

  self.is_implemented = true
  self.initial_cooldown = 2
  self.initial_delay = 0
  self.is_priority = true
  self.damage_multiplier = 0
  self.bypass = []

  def update_defender(attacker, defender)
    defender.add_modifier(Modifiers::PreventSwap.new(2, 'other'))
  end

  def damage_defender(attacker, defender)
    result = super
    # stun the defender
    defender.is_stunned = rand(100) < 100.0 * (100.0 - defender.resistance(:stun) / 100.0)
    result
  end


end
