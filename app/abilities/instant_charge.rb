# Instant Charge
class InstantCharge < Ability

  self.is_implemented = true
  self.cooldown = 2
  self.delay = 1
  self.is_priority = true
  self.damage_multiplier = 1
  self.bypass = []

  def damage_defender(attacker, defender)
    result = super
    # stun the defender with 75% probability, subject to resistance
    defender.is_stunned = rand(100) < 75.0 * (100.0 - defender.resistance(:stun)) / 100.0
    result
  end

end
