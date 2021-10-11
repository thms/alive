class PiercingRevenge < Ability

  self.is_implemented = true
  self.cooldown = 1
  self.delay = 1
  self.trigger = "regular"
  self.is_priority = false
  self.damage_multiplier = 0.4
  self.bypass = [:armor,]
  self.is_rending_attack = true
  self.is_counter = false
  self.is_swap_out = false

  # add and remove modifiers for the attacker
  def update_attacker(attacker)
  end

  # same as above but called when the attacker is in revenge mode
  def update_attacker_revenge(attacker)
    self.delay = 0
    self.cooldown = 1
  end

  # remove modifiers for the defender before damage is done
  def update_defender(defender)
    defender.destroy_shields
  end

  # remove modifiers for the defender before damage is done in revenge mode
  def update_defender_revenge(defender)
    defender.destroy_shields
  end

  # add modifiers for the defender after damage is done
  def update_defender_after_damage(defender)
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
