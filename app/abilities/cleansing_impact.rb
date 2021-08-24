# Cleansing impact
# Deal damage 1.5x
# Cleanse self
class CleansingImpact < Ability

  self.is_implemented = true
  self.cooldown = 2
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 1.5
  self.bypass = []

  def update_attacker(attacker)
    attacker.cleanse(:all)
  end

end
