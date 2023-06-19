class DeterminedStrike < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.trigger = "regular"
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = [:dodge, :cloak,]
  self.is_rending_attack = false
  self.is_counter = false
  self.is_swap_out = false
  self.attacker_team_targets = 'self'
  self.defender_team_targets = 'fastest'

  # add and remove modifiers for the attacker
  def update_attacker(attacker, mode = :pvp)
    attacker.targets('self').each {|target| target.cleanse(:damage_over_time)}
    attacker.targets('self').each {|target| target.cleanse(:distraction)}
  end

  # same as above but called when the attacker is in revenge mode
  def update_attacker_revenge(attacker, mode = :pvp)
  end

  # remove modifiers for the defender before damage is done
  def update_defender(defender, mode = :pvp)
    defender.targets('fastest').each {|target| target.remove_critical_chance_increase}
    defender.targets('fastest').each {|target| target.remove_attack_increase}
    defender.targets('fastest').each {|target| target.remove_speed_increase}
  end

  # remove modifiers for the defender before damage is done in revenge mode
  def update_defender_revenge(defender, mode = :pvp)
  end

  # add modifiers for the defender after damage is done
  def update_defender_after_damage(defender, mode = :pvp)
    defender.targets('fastest').each {|target| target.add_modifier(Modifiers::Vulnerability.new(50, 2, 1))}
    defender.targets('fastest').each {|target| target.add_modifier(Modifiers::Distraction.new(50, 1, 2))}
    defender.targets('fastest').each {|target| target.add_modifier(Modifiers::ReduceCriticalChance.new(100, 1, 2))}
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
