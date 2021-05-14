# Priortiy
# self cleanse
# Gain 100% chance to dodge 66.7% of damage for 2 attacks, lasting this turn
# Increase speed by 10% for two turns

class Sidestep < Ability

  self.is_implemented = true
  self.initial_cooldown = 0
  self.initial_delay = 0
  self.is_priority = true
  self.damage_multiplier = 0
  self.bypass = []

  def update_attacker(attacker, defender)
    attacker.cleanse(:all)
    attacker.add_modifier(Modifiers::Dodge.new(100, 0, 2))
    attacker.add_modifier(Modifiers::IncreaseSpeed.new(10, 2, nil))
  end

end
