# Fierce strike, cleanse vulnerable, remove taunt, destroy shields, bypass armor, attack 1x
class FierceStrike < Ability

  self.is_implemented = true
  self.initial_cooldown = 0
  self.initial_delay = 0
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = [:armor]

  def update_attacker(attacker, defender)
    attacker.cleanse(:vulnerable)
  end

  def update_defender(attacker, defender)
    defender.destroy_shields
    defender.remove_taunt
  end

end
