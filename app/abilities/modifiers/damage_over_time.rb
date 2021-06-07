class Modifiers::DamageOverTime < Modifiers::Modifier

  self.is_defense = false
  self.is_attack = !self.is_defense
  self.destroy = []
  self.cleanse = [:dmage_over_time]
  self.is_positive = false

  def initialize(percent, turns)
    @value = percent
    self.turns = turns
    self.attacks = nil
    super()
  end

  # this is additive, so if multiple are active at any given time their value adds up
  # so that if two modifiers are active at the same time, their percentages are added to arrive at the total dot to apply
  def execute(attributes)
    attributes[:damage_over_time] += @value
  end
end
