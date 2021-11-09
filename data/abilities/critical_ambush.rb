class CriticalAmbush < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.trigger = "swap-in"
  self.is_priority = true
  self.damage_multiplier = 0
  self.bypass = []
  self.is_rending_attack = false
  self.is_counter = false

  # add and remove modifiers for the attacker
  def update_attacker(attacker)
    attacker.add_modifier(Modifiers::Dodge.new(75, 2, 2))
    attacker.add_modifier(Modifiers::IncreaseCriticalChance.new(50, 2, 2))
    attacker.add_modifier(Modifiers::IncreaseSpeed.new(30, 2, nil))
  end

  # same as above but called when the attacker is in revenge mode
  def update_attacker_revenge(attacker)
  end

  # remove modifiers for the defender before damage is done
  def update_defender(defender)
  end

  # remove modifiers for the defender before damage is done in revenge mode
  def update_defender_revenge(defender)
  end

  # add modifiers for the defender after damage is done
  def update_defender_after_damage(defender)
    defender.add_modifier(Modifiers::Distraction.new(50, 1, 2))
    defender.add_modifier(Modifiers::PreventSwap.new(2, 'other'))
  end

  # add modifiers for the defender after damage is done in revenge mode
  def update_defender_after_damage_revenge(defender)
  end

  # special logic for some attacks
  def damage_defender(attacker, defender)
    result = super
    result
  end

end
