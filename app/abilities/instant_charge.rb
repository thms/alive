class InstantCharge < Ability

  self.is_implemented = true
  self.cooldown = 2
  self.delay = 1
  self.trigger = "regular"
  self.is_priority = true
  self.damage_multiplier = 1
  self.bypass = []
  self.is_rending_attack = false
  self.is_counter = false
  self.is_swap_out = false
  self.attacker_team_targets = nil
  self.defender_team_targets = 'highest_dmg'

  # add and remove modifiers for the attacker
  def update_attacker(attacker, mode = :pvp)
  end

  # same as above but called when the attacker is in revenge mode
  def update_attacker_revenge(attacker, mode = :pvp)
  end

  # remove modifiers for the defender before damage is done
  def update_defender(defender, mode = :pvp)
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
    defender.targets('highest_dmg').each {|target| target.is_stunned = rand(100) < 75.0 * (100.0 - target.resistance(:stun)) / 100.0}
    result
  end

end
