# TODO:
class DistractingRampage < Ability

  self.is_implemented = true
  self.initial_cooldown = 2
  self.initial_delay = 1
  self.is_priority = false
  self.damage_multiplier = 2
  self.bypass = []

  def update_defender(attacker, defender)
    defender.add_modifier(Modifiers::Distract.new(50, 2, 4))
  end

end
