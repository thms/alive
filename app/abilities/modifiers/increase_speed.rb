class Modifiers::IncreaseSpeed < Modifiers::Modifier

  self.cleanse = []
  self.is_defense = true
  self.is_attack = !self.is_defense

  def initialize(increase, turns, attacks)
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
