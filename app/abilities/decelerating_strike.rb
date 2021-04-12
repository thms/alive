# Decelerating strike
# Deal damage
# Reduce opponent's speed by 10%
class DeceleratingStrike < Ability

  self.initial_cooldown = 0
  self.initial_delay = 0
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = []

  def update_defender(attacker, defender)
    defender.add_modifier(Modifiers::DecreaseSpeed.new(0.1))
  end

end
