# Target lowest HP
# reduce damage by 50% for 2 attacks, lasting 1 turn
# Precise attack 2x
class PrecisePounce < Ability

  self.is_implemented = true
  self.cooldown = 1
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 2
  self.bypass = [:dodge, :cloak]

  def update_defender_after_damage(attacker, defender)
    defender.add_modifier(Modifiers::Distraction.new(50, 1, 2))
  end

end
