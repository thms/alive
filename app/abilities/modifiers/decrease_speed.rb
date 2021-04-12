class Modifiers::DecreaseSpeed < Modifiers::Modifier

  self.attacks = 1
  self.turns = 1
  self.is_defense = true
  self.is_attack = !self.is_defense
  self.cleanse = [:all]

  def initialize(decrease)
    @value = decrease
    super()
  end

  def execute(attributes)
    attributes[:speed] = ((1.0 - @value) * attributes[:speed]).to_int
  end
end
