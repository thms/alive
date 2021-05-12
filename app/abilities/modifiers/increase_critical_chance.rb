class Modifiers::IncreaseCriticalChance < Modifiers::Modifier

  self.is_defense = true
  self.is_attack = !self.is_defense
  self.cleanse = []
  self.destroy = []
  self.is_positive = true

  # increase is abolsute in percent, e..g if base is 40% and the increase is 50% the total probability is 90%
  def initialize(increase)
    @value = increase
    self.turns = 1
    self.attacks = nil
    super()
  end

  def execute(attributes)
    attributes[:critical_chance] += @value
  end
end
