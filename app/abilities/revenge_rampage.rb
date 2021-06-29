# on revenge: no cooldown of the rampage
class RevengeRampage < Ability

  self.is_implemented = true
  self.cooldown = 1
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 2
  self.bypass = []

  def damage_defender(attacker, defender)
    self.cooldown = 0 if attacker.is_revenge
    super
  end

end
