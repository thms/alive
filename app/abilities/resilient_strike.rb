class ResilientStrike < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.trigger = "regular"
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = []
  self.is_rending_attack = false
  self.is_counter = false
  self.is_swap_out = false
  self.attacker_team_targets = 'self'
  self.defender_team_targets = 'lowest_hp'

  # add and remove modifiers for the attacker
  def update_attacker(attacker, mode = :pvp)
    attacker.targets('self').each {|target| target.cleanse(:distraction)}
  end

  # same as above but called when the attacker is in revenge mode
  def update_attacker_revenge(attacker, mode = :pvp)
  end

  # remove modifiers for the defender before damage is done
  def update_defender(defender, mode = :pvp)
    defender.targets('lowest_hp').each {|target| target.remove_speed_increase}
    defender.targets('lowest_hp').each {|target| target.remove_cloak}
    defender.targets('lowest_hp').each {|target| target.remove_dodge}
  end

  # remove modifiers for the defender before damage is done in revenge mode
  def update_defender_revenge(defender, mode = :pvp)
  end

  # add modifiers for the defender after damage is done
  def update_defender_after_damage(defender, mode = :pvp)
    defender.targets('lowest_hp').each {|target| target.add_modifier(Modifiers::Vulnerability.new(50, 2, 1))}
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
