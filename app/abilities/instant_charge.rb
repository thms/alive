# Instant Charge
# TODO: add stun modifier
class InstantCharge < Ability

  self.initial_cooldown = 2
  self.initial_delay = 1
  self.is_priority = true

  def damage_defender(attacker, defender)
    defender.current_health -= attacker.damage
    #stun the defender
    # TODO: add in resistance of defender
    defender.is_stunned = (rand <= 0.75)
  end

end
