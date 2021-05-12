class Modifiers::ReduceCriticalChance < Modifiers::Modifier

  self.is_defense = false
  self.is_attack = !self.is_defense
  self.cleanse = [:all]
  self.destroy = []
  self.is_positive = false

  def initialize(reduction)
    @value = reduction
    self.turns = 1
    self.attacks = nil
    super()
  end

  def execute(attributes)
    attributes[:critical_chance] -= @value
  end
end
