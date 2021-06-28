class Modifiers::IncreaseSpeed < Modifiers::Modifier

  self.cleanse = []
  self.is_defense = false
  self.is_attack = !self.is_defense
  self.is_positive = true
  self.destroy = []

  # API: increase is the amount in % to decrease speed: speed = (1 + decrease/100 ) * speed
  # turns: the number of turns to be active after this current turn ends
  # attacks: the number of attacks
  def initialize(increase, turns, attacks = nil)
    @value = increase
    self.turns = turns + 1
    self.attacks = attacks
  super()
  end

  # Speed increase / decrease is additive percentages when multiple modifiers are active
  def execute(attributes)
    attributes[:speed] += @value
  end

end
