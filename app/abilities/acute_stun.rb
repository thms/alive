# Target highest damage: 100% chane to stun for 1 turn
class AcuteStun < Ability

  self.is_implemented = true
  self.initial_cooldown = 2
  self.initial_delay = 0
  self.is_priority = false
  self.damage_multiplier = 0
  self.bypass = []

  def damage_defender(attacker, defender)
    result = super
    # stun the defender
    # TODO: add in resistance of defender
    defender.is_stunned = true
    result
  end

end
