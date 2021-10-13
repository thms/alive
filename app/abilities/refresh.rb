class Refresh < Ability

  self.is_implemented = true
  self.cooldown = 2
  self.delay = 0
  self.trigger = "regular"
  self.is_priority = false
  self.damage_multiplier = 0
  self.bypass = []
  self.is_rending_attack = false
  self.is_counter = false
  self.is_swap_out = false

  # add and remove modifiers for the attacker
  def update_attacker(attacker)
    attacker.zelf.each {|target| target.heal(1 * attacker.zelf.damage)}
    attacker.zelf.each {|target| target.add_modifier(Modifiers::IncreaseSpeed.new(10, 2, nil))}
    attacker.zelf.each {|target| target.cleanse(:all)}
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
