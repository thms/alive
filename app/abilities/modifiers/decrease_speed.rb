class Modifiers::DecreaseSpeed < Modifiers::Modifier

  self.is_defense = true
  self.is_attack = !self.is_defense
  self.cleanse = [:all]

  def initialize(decrease, turns, attacks)
    @value = decrease
    self.turns = turns
    self.attacks = attacks
    super()
  end

  def execute(attributes)
    attributes[:speed] -= @value
  end
end
