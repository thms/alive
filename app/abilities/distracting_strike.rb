# Distracting strike
# Reduce damage by 50% for 4 attacks , lasting 2 turns
# mechanism for distraction is either: each individually active one takes 50% points of the original
# so two of these active at the same time would result in 100% reduction of damage
# Attack 1x
class DistractingStrike < Ability

  self.initial_cooldown = 0
  self.initial_delay = 0
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = []

  def update_defender(attacker, defender)
    defender.add_modifier(Modifiers::Distract.new(distraction: 0.5, attacks: 4, turns: 2))
  end

end
