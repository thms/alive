# Simple strike, just deal attackers to defnder, no other effects
class Strike < Ability

  self.cooldown = 0
  self.delay = 0

  def damage_defender
    @defender.current_health -= @attacker.damage
  end

end
