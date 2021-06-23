class Modifiers::DecreaseSpeed < Modifiers::Modifier

  self.is_defense = true
  self.is_attack = !self.is_defense
  self.cleanse = [:all, :decrease_speed]
  self.destroy = []
  self.is_positive = false

  # API: decrease is the amount in % to decrease speed: speed = (1 - decrease/100 ) * speed
  # turns: the number of turns to be active after this current turn ends
  # attacks: the number of attacks
  def initialize(decrease, turns, attacks = nil)
    @value = decrease
    self.turns = turns
    self.attacks = attacks
    super()
  end

  def execute(attributes)
    attributes[:speed] -= @value
  end
end
