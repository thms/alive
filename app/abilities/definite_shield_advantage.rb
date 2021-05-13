# TODO:
class DefiniteShieldAdvantage < Ability

  self.is_implemented = true
  self.initial_cooldown = 2
  self.initial_delay = 1
  self.is_priority = false
  self.damage_multiplier = 2
  self.bypass = [:armor]

  def update_attacker(attacker, defender)
    attacker.add_modifier(Modifiers::Shields.new(50, 1, 4))
  end

  def update_defender(attacker, defender)
    defender.destroy_shields
    defender.remove_cloak
    defender.remove_dodge
  end

end
