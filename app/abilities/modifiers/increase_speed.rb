class Modifiers::IncreaseSpeed < Modifiers::Modifier

  self.cleanse = []
  self.is_defense = true
  self.is_attack = !self.is_defense
  self.is_positive = true
  self.destroy = []

  def initialize(increase, turns, attacks = nil)
    @value = increase
    self.turns = turns
    self.attacks = attacks
  super()
  end

  # Speed increase / decrease is additive percentages when multiple modifiers are active
  def execute(attributes)
    attributes[:speed] += @value
  end

end
