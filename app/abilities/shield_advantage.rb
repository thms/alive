# TODO:
class ShieldAdvantage < Ability

  self.is_implemented = true
  self.cooldown = 1
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = [:armor]

  def update_attacker(attacker, defender)
    attacker.add_modifier(Modifiers::Shields.new(50, 2, 4))
  end

  def update_defender(attacker, defender)
    defender.destroy_shields
  end
end
