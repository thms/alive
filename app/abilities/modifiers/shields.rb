class Modifiers::Shields < Modifiers::Modifier

  self.is_defense = true
  self.is_attack = !self.is_defense
  self.destroy = [:shields]
  self.cleanse = []
  self.is_positive = true

  def initialize(strength, turns, attacks)
    @value = strength
    self.turns = turns
    self.attacks = attacks
    super()
  end

  # shields are not additiv, but the maximum value applies
  def execute(attributes)
    attributes[:shields] = [@value, attributes[:shields]].max
  end
end
