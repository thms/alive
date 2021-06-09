class InstantDistraction < Ability

  self.is_implemented = true
  self.initial_cooldown = 1
  self.initial_delay = 0
  self.is_priority = true
  self.damage_multiplier = 0
  self.bypass = []

  def update_defender(attacker, defender)
    defender.add_modifier(Modifiers::Distraction.new(100, 1, 2))
  end

end
