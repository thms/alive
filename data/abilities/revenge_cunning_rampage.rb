class RevengeCunningRampage < Ability

  self.is_implemented = true
  self.cooldown = 1
  self.delay = 1
  self.trigger = "regular"
  self.is_priority = false
  self.damage_multiplier = 2
  self.bypass = []
  self.is_rending_attack = false
  self.is_counter = false

  # add and remove modifiers for the attacker
  def update_attacker(attacker)
    attacker.cleanse(:damage_over_time)
  end

  # same as above but called when the attacker is in revenge mode
  def update_attacker_revenge(attacker)
    attacker.cleanse(:damage_over_time)
    self.delay = 0
    self.cooldown = 1
  end

  # remove modifiers for the defender before damage is done
  def update_defender(defender)
    defender.remove_critical_chance_increase
    defender.remove_attack_increase
  end

  # remove modifiers for the defender before damage is done in revenge mode
  def update_defender_revenge(defender)
    defender.remove_critical_chance_increase
    defender.remove_attack_increase
  end

  # add modifiers for the defender after damage is done
  def update_defender_after_damage(defender)
    defender.add_modifier(Modifiers::Distraction.new(50, 1, 2))
    defender.add_modifier(Modifiers::ReduceCriticalChance.new(100, 1, 2))
  end

  # add modifiers for the defender after damage is done in revenge mode
  def update_defender_after_damage_revenge(defender)
    defender.add_modifier(Modifiers::Distraction.new(50, 1, 2))
    defender.add_modifier(Modifiers::ReduceCriticalChance.new(100, 1, 2))
  end

  # special logic for some attacks
  def damage_defender(attacker, defender)
    result = super
    result
  end

end
