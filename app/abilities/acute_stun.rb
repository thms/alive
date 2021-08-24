# Target highest damage: 100% chance to stun for 1 turn
class AcuteStun < Ability

  self.is_implemented = true
  self.cooldown = 2
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 0
  self.bypass = []

  def damage_defender(attacker, defender)
    result = super
    # stun the defender, with probability depending on the resitance of the defender
    defender.is_stunned = rand(100) < 100.0 * (100.0 - defender.resistance(:stun)) / 100.0
    result
  end

end
