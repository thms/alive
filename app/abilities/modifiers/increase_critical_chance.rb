class Modifiers::IncreaseCriticalChance < Modifiers::Modifier

  self.tick_when_attacked = false
  self.tick_when_attacking = true
  self.cleanse = []
  self.destroy = []
  self.is_positive = true

  # increase is absolute in percent, e..g if base is 40% and the increase is 50% the total probability is 90%
  def initialize(increase, turns, attacks = nil)
    @value = increase
    self.turns = turns + 1
    self.attacks = attacks
    super()
  end

  def execute(attributes)
    attributes[:critical_chance] += @value
  end
end
