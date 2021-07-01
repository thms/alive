# Decelerating strike
# Deal damage
# Reduce opponent's speed by 10%
class DeceleratingStrike < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = []

  def update_defender_after_damage(attacker, defender)
    defender.add_modifier(Modifiers::DecreaseSpeed.new(10, 1))
  end

end
