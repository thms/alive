# Cleansing strike
# Deal damage 1x
# Cleanse self
class CleansingStrike < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = []

  def update_attacker(attacker)
    attacker.cleanse(:all)
  end

end
