# Rampage
# Deal 2x damage
class Rampage < Ability

  self.cooldown = 1
  self.delay = 1

  def damage_defender
    @defender.current_health -= 2 * @attacker.damage
  end

end
