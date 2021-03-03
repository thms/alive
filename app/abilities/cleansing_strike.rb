# Cleansing strike
# Deal damage 1x
# Cleanse self
class CleansingStrike < Ability

  self.initial_cooldown = 0
  self.initial_delay = 0
  self.is_priority = false

  def update_attacker(attacker, defender)
    attacker.cleanse(:all)
  end

  def damage_defender(attacker, defender)
    defender.current_health -= attacker.damage
  end

end
