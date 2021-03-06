class Modifiers::DecreaseSpeed < Modifiers::Modifier

  self.tick_when_attacked = false
  self.tick_when_attacking = false
  self.cleanse = [:all, :decrease_speed]
  self.destroy = []
  self.is_positive = false

  # API: decrease is the amount in % to decrease speed: speed = (1 - decrease/100 ) * speed
  # turns: start to count down at the end of the target's next turn, hence turns + 1
  # attacks: the number of attacks
  def initialize(decrease, turns, attacks = nil)
    @value = decrease
    self.turns = turns + 1
    self.attacks = attacks
    super()
  end

  def execute(attributes)
    attributes[:speed] -= @value
  end
end
