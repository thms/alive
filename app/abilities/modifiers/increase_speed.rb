class Modifiers::IncreaseSpeed < Modifiers::Modifier

  self.cleanse = []
  self.tick_when_attacked = false
  self.tick_when_attacking = true
  self.is_positive = true
  self.destroy = []

  # API: increase is the amount in % to decrease speed: speed = (1 + decrease/100 ) * speed
  # turns: start to count down at the end of the target's next turn, hence turns + 1
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
