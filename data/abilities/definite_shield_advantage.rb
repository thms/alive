class DefiniteShieldAdvantage < Ability

  self.is_implemented = true
  self.cooldown = 2
  self.delay = 1
  self.trigger = "regular"
  self.is_priority = false
  self.damage_multiplier = 2
  self.bypass = [:armor,]
  self.is_rending_attack = false
  self.is_counter = false

  # add and remove modifiers for the attacker
  def update_attacker(attacker)
    attacker.add_modifier(Modifiers::Shields.new(50, 1, 4))
  end

  # same as above but called when the attacker is in revenge mode
  def update_attacker_revenge(attacker)
  end

  # remove modifiers for the defender before damage is done
  def update_defender(defender)
    defender.destroy_shields
    defender.remove_taunt
    defender.remove_cloak
    defender.remove_dodge
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
