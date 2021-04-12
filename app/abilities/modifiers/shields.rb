class Modifiers::Shields < Modifiers::Modifier

  self.is_defense = true
  self.is_attack = !self.is_defense
  self.destroy = [:shields]

  def initialize(strength, turns, attacks)
    @value = strength
    self.turns = turns
    self.attacks = attacks
    super()
  end

  # this should be additive with respect to the original shields
  # so that if two modifiers are active at the same time, their percentages are added to arrive at the total strength of the shields
  def execute(attributes)
    attributes[:shields] += @value
  end
end
