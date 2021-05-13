class Modifiers::IncreaseCriticalChance < Modifiers::Modifier

  self.is_defense = false
  self.is_attack = !self.is_defense
  self.cleanse = []
  self.destroy = []
  self.is_positive = true

  # increase is absolute in percent, e..g if base is 40% and the increase is 50% the total probability is 90%
  def initialize(increase, turns, attacks = nil)
    @value = increase
    self.turns = turns
    self.attacks = attacks
    super()
  end

  def execute(attributes)
    attributes[:critical_chance] += @value
  end
end
