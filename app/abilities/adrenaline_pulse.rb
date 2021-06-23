# Priority. Self: Heal 1200 HP
class AdrenalinePulse < Ability

  self.is_implemented = true
  self.initial_cooldown = 3
  self.initial_delay = 0
  self.is_priority = true
  self.damage_multiplier = 0
  self.bypass = []

  def update_attacker(attacker, defender)
    attacker.heal(attacker.damage)
  end

end
