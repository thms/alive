# Target highest Damage: reduce damage by 50% for 2 attacks, lasting 1 turn.
# Attack 2x
class HighPounce < Ability

  self.is_implemented = true
  self.initial_cooldown = 1
  self.initial_delay = 0
  self.is_priority = false
  self.damage_multiplier = 2.0
  self.bypass = []

  def update_defender(attacker, defender)
    defender.add_modifier(Modifiers::Distract.new(50, 1, 2))
  end

end
