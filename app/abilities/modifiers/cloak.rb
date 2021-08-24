# reduces the attack damage by 67% with a probability of x for n turns, m attacks
# and increases the next hits attack
# both expires when used on own attack
class Modifiers::Cloak < Modifiers::Modifier

  self.tick_when_attacked = false
  self.tick_when_attacking = true
  self.destroy = [:cloak]
  self.cleanse = []
  self.is_positive = true

  # 2x damage: damage = 100
  # 3x damage: damage = 200
  def initialize(probability, damage, turns, attacks)
    @probability = probability
    @damage = damage # in percent
    self.turns = turns
    self.attacks = attacks
    super()
  end

  # this should be additive with respect to the original dodge
  # only one dodge can be active for a given creature
  def execute(attributes)
    attributes[:dodge] = @probability
    attributes[:damage] += @damage
  end
end
