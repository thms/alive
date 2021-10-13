class SwapInResilientStrike < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.trigger = "swap-in"
  self.is_priority = true
  self.damage_multiplier = 1
  self.bypass = []
  self.is_rending_attack = false
  self.is_counter = false
  self.is_swap_out = false

  # add and remove modifiers for the attacker
  def update_attacker(attacker)
    attacker.zelf.each {|target| target.add_modifier(Modifiers::PreventSwap.new(2, 'self'))}
    attacker.zelf.each {|target| target.cleanse(:distraction)}
  end

  # same as above but called when the attacker is in revenge mode
  def update_attacker_revenge(attacker)
  end

  # remove modifiers for the defender before damage is done
  def update_defender(defender)
    defender.lowest_hp.each {|target| target.remove_speed_increase}
    defender.lowest_hp.each {|target| target.remove_cloak}
    defender.lowest_hp.each {|target| target.remove_dodge}
  end

  # remove modifiers for the defender before damage is done in revenge mode
  def update_defender_revenge(defender)
  end

  # add modifiers for the defender after damage is done
  def update_defender_after_damage(defender)
    defender.lowest_hp.each {|target| target.add_modifier(Modifiers::Vulnerability.new(50, 2, 1))}
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
