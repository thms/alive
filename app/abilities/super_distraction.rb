class SuperDistraction < Ability

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

  # add and remove modifiers for the attacker
  def update_attacker(attacker)
  end

  # same as above but called when the attacker is in revenge mode
  def update_attacker_revenge(attacker)
  end

  # remove modifiers for the defender before damage is done
  def update_defender(defender)
    defender.highest_dmg.each {|target| target.remove_dodge}
  end

  # remove modifiers for the defender before damage is done in revenge mode
  def update_defender_revenge(defender)
  end

  # add modifiers for the defender after damage is done
  def update_defender_after_damage(defender)
    defender.all_opponents.each {|target| target.add_modifier(Modifiers::Distraction.new(50, 1, 2))}
    defender.highest_dmg.each {|target| target.add_modifier(Modifiers::Distraction.new(50, 1, 2))}
    defender.highest_dmg.each {|target| target.add_modifier(Modifiers::DamageOverTime.new(25, 2))}
  end

  # add modifiers for the defender after damage is done in revenge mode
  def update_defender_after_damage_revenge(defender)
  end

  # special logic for some attacks
  def damage_defender(attacker, defender)
    result = super
    defender.highest_dmg.each {|target| target.is_stunned = rand(100) < 25.0 * (100.0 - target.resistance(:stun)) / 100.0}
    result
  end

end
