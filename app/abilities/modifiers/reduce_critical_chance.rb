class Modifiers::ReduceCriticalChance < Modifiers::Modifier

  self.tick_when_attacked = false
  self.tick_when_attacking = true
  self.cleanse = [:all, :critical]
  self.destroy = []
  self.is_positive = false

  def initialize(reduction, turns, attacks = nil)
    @value = reduction
    self.turns = turns + 1
    self.attacks = attacks
    super()
  end

  def execute(attributes)
    attributes[:critical_chance] -= @value
  end
end
