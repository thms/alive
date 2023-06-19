class DefiniteStrike < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.trigger = "regular"
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = [:armor,]
  self.is_rending_attack = false
  self.is_counter = false
  self.is_swap_out = false
  self.attacker_team_targets = nil
  self.defender_team_targets = 'most_pos'

  # add and remove modifiers for the attacker
  def update_attacker(attacker, mode = :pvp)
  end

  # same as above but called when the attacker is in revenge mode
  def update_attacker_revenge(attacker, mode = :pvp)
  end

  # remove modifiers for the defender before damage is done
  def update_defender(defender, mode = :pvp)
    defender.targets('most_pos').each {|target| target.destroy_shields}
    defender.targets('most_pos').each {|target| target.remove_taunt}
    defender.targets('most_pos').each {|target| target.remove_cloak}
    defender.targets('most_pos').each {|target| target.remove_dodge}
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
