class RendingCounterAttack < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.trigger = "counter"
  self.is_priority = false
  self.damage_multiplier = 0.25
  self.bypass = [:armor,]
  self.is_rending_attack = true
  self.is_counter = true
  self.is_swap_out = false
  self.attacker_team_targets = nil
  self.defender_team_targets = 'attacker'

  # add and remove modifiers for the attacker
  def update_attacker(attacker, mode = :pvp)
  end

  # same as above but called when the attacker is in revenge mode
  def update_attacker_revenge(attacker, mode = :pvp)
  end

  # remove modifiers for the defender before damage is done
  def update_defender(defender, mode = :pvp)
    defender.targets('attacker').each {|target| target.destroy_shields}
  end

  # remove modifiers for the defender before damage is done in revenge mode
  def update_defender_revenge(defender, mode = :pvp)
  end

  # add modifiers for the defender after damage is done
  def update_defender_after_damage(defender, mode = :pvp)
  end

  # add modifiers for the defender after damage is done in revenge mode
  def update_defender_after_damage_revenge(defender, mode = :pvp)
  end

  # special logic for some attacks
  def damage_defender(attacker, defender, mode = :pvp)
    result = super
    result
  end

end
