# Target lowest HP: Remove damage and critical hit increase.
# BBYpass dodge and armor
# Precise attack 1x
class CraftyStrike < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = [:armor, :dodge]

  def update_defender(defender)
    defender.remove_critical_chance_increase
    defender.remove_attack_increase
  end
end
