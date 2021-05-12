# TODO:
class DeceleratingRampage < Ability

  self.is_implemented = true
  self.initial_cooldown = 1
  self.initial_delay = 1
  self.is_priority = false
  self.damage_multiplier = 2.0
  self.bypass = []

  def update_defender(attacker, defender)
    defender.add_modifier(Modifiers::DecreaseSpeed.new(50, 2, nil))
  end


end
