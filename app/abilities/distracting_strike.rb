# Distracting strike
# Reduce damage by 50% for 4 attacks , lasting 2 turns
# mechanism for distraction is either: each individually active one takes 50% points of the original
# so two of these active at the same time would result in 100% reduction of damage
# Attack 1x
class DistractingStrike < Ability

  self.is_implemented = true
  self.cooldown = 2
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = []

  def update_defender(attacker, defender)
    defender.add_modifier(Modifiers::Distraction.new(50, 2, 4))
  end

end
