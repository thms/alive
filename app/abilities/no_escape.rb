# This fires on swap out attempt of another dinosaur
# and may prevent him from swapping out.
class NoEscape < Ability

  self.is_implemented = true
  self.initial_cooldown = 0
  self.initial_delay = 0
  self.is_priority = false
  self.damage_multiplier = 0
  self.bypass = []

  def update_defender(attacker, defender)
    defender.add_modifier(Modifiers::PreventSwap.new(1, 'other'))
  end

end
