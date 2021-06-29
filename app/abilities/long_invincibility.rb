# Self: 100% shields for 2 attacks, lasting 3 turns
class LongInvincibility < Ability

  self.is_implemented = true
  self.cooldown = 3
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 0
  self.bypass = []

  def update_attacker(attacker, defender)
    attacker.add_modifier(Modifiers::Shields.new(100, 3, 2))
  end
end
