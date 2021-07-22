# Reduce damage by x percent
class Modifiers::Distraction < Modifiers::Modifier

  self.cleanse = [:all, :distraction]
  self.tick_when_attacked = false
  self.tick_when_attacking = true
  self.destroy = []
  self.is_positive = false
  self.cleanse = [:distraction, :all]

  def initialize(distraction, turns, attacks)
    @value = distraction
    self.turns = turns
    self.attacks = attacks
    super()
  end

  # this should be additive with respect to the original damage
  # and this works on the other, not on self, by reducing their damage attribute
  # Counts down at the end of the tartget's turn / action
  def execute(attributes)
    attributes[:distraction] += @value
  end

  def tick
    super
  end
end
