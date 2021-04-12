# Cleansing strike
# Deal damage 1x
# Cleanse self
class CleansingStrike < Ability

  self.initial_cooldown = 0
  self.initial_delay = 0
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = []

  def update_attacker(attacker, defender)
    attacker.cleanse(:all)
  end

end
