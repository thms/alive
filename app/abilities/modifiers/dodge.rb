# reduces the attack damage by 67% with a probablity of x for n turns, m attacks
class Modifiers::Dodge < Modifiers::Modifier

  self.is_defense = true
  self.is_attack = !self.is_defense
  self.destroy = [:dodge]
  self.is_positive = true

  def initialize(chance, turns, attacks)
    @value = chance
    self.turns = turns
    self.attacks = attacks
    super()
  end

  # this should be additive with respect to the original shields
  # only one dodge can be active for a given creature
  def execute(attributes)
    attributes[:dodge] = 67 if (100 * rand) <= @value
  end
end
