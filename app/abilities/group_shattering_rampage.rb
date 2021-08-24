# TODO:
class GroupShatteringRampage < Ability

  self.is_implemented = true
  self.cooldown = 2
  self.delay = 1
  self.is_priority = false
  self.damage_multiplier = 2
  self.bypass = [:armor]

  def update_defender(defender)
    defender.destroy_shields
    defender.remove_taunt
  end

end
