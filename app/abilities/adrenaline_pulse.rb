# Priority. Self: Heal 1200 HP
class AdrenalinePulse < Ability

  self.is_implemented = true
  self.cooldown = 3
  self.delay = 0
  self.is_priority = true
  self.damage_multiplier = 0
  self.bypass = []

  def update_attacker(attacker)
    attacker.heal(attacker.damage)
  end

end
