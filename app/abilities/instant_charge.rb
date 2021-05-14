# Instant Charge
# TODO: add stun modifier
class InstantCharge < Ability

  self.is_implemented = true
  self.initial_cooldown = 2
  self.initial_delay = 1
  self.is_priority = true
  self.damage_multiplier = 1
  self.bypass = []

  def damage_defender(attacker, defender)
    result = super
    # stun the defender
    # TODO: add in resistance of defender
    defender.is_stunned = (rand <= 0.75)
    result
  end

end
