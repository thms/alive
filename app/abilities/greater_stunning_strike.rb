# Tareget highest damage: 75% chance to stun for 1 turn. Attack 1x
class GreaterStunningStrike < Ability

  self.is_implemented = true
  self.initial_cooldown = 2
  self.initial_delay = 1
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = []

  def damage_defender(attacker, defender)
    result = super
    # stun the defender
    defender.is_stunned = rand(100) < 75 * (100.0 - defender.resistance(:stun) / 100.0)
    result
  end

end
