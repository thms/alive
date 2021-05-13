# Targe lowest HP
# reduce damage by 50% doe 2 attacks, lasting 1 turn
# Precise attack 2x
class PrecisePounce < Ability

  self.is_implemented = true
  self.initial_cooldown = 1
  self.initial_delay = 0
  self.is_priority = false
  self.damage_multiplier = 2
  self.bypass = [:dodge]

  def update_defender(attacker, defender)
    defender.add_modifier(Modifiers::Distraction.new(50, 1, 2))
  end

end
