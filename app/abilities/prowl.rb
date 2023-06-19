class Prowl < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.trigger = "regular"
  self.is_priority = true
  self.damage_multiplier = 0
  self.bypass = []
  self.is_rending_attack = false
  self.is_counter = false
  self.is_swap_out = false
  self.attacker_team_targets = 'self'
  self.defender_team_targets = nil

  # add and remove modifiers for the attacker
  def update_attacker(attacker, mode = :pvp)
    attacker.targets('self').each {|target| target.add_modifier(Modifiers::IncreaseCriticalChance.new(50, 2, 2))}
    attacker.targets('self').each {|target| target.add_modifier(Modifiers::Dodge.new(75, 1, 2))}
    attacker.targets('self').each {|target| target.cleanse(:all)}
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
    result
  end

end
