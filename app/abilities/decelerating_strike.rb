# Decelerating strike
# Deal damage
# Reduce opponent's speed by 10%
class DeceleratingStrike < Ability

  self.cooldown = 0
  self.delay = 0

  def update_defender
    @defender.current_speed = (@defender.current_speed * 90 / 100 ).to_int
  end

  def damage_defender
    @defender.current_health -= @attacker.damage
  end

end
