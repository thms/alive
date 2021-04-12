class Modifiers::Distract < Modifiers::Modifier

  self.cleanse = [:all, :distraction]
  self.is_defense = true
  self.is_attack = !self.is_defense

  def initialize(distraction, turns, attacks)
    @value = distraction
    self.turns = turns
    self.attacks = attacks
    super()
  end

  # this should be additive with respect to the original damage
  # and this works on the other, not on self, by reducing their damage attribute
  def execute(attributes)
    attributes[:speed] = ((1.0 - @value) * attributes[:speed]).to_int
  end
end
