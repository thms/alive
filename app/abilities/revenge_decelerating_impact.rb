class RevengeDeceleratingImpact < Ability

  self.is_implemented = true
  self.cooldown = 1
  self.delay = 0
  self.trigger = "regular"
  self.is_priority = false
  self.damage_multiplier = 1.5
  self.bypass = []
  self.is_rending_attack = false
  self.is_counter = false
  self.is_swap_out = false
  self.attacker_team_targets = nil
  self.defender_team_targets = 'fastest'

  # add and remove modifiers for the attacker
  def update_attacker(attacker, mode = :pvp)
  end

  # same as above but called when the attacker is in revenge mode
  def update_attacker_revenge(attacker, mode = :pvp)
    self.delay = 0
    self.cooldown = 1
  end

  # remove modifiers for the defender before damage is done
  def update_defender(defender, mode = :pvp)
  end

  # remove modifiers for the defender before damage is done in revenge mode
  def update_defender_revenge(defender, mode = :pvp)
  end

  # add modifiers for the defender after damage is done
  def update_defender_after_damage(defender, mode = :pvp)
    defender.targets('fastest').each {|target| target.add_modifier(Modifiers::DecreaseSpeed.new(50, 2, nil))}
  end

  # add modifiers for the defender after damage is done in revenge mode
  def update_defender_after_damage_revenge(defender, mode = :pvp)
    defender.targets('fastest').each {|target| target.add_modifier(Modifiers::DecreaseSpeed.new(50, 2, nil))}
  end

  # special logic for some attacks
  def damage_defender(attacker, defender, mode = :pvp)
    result = super
    result
  end

end
