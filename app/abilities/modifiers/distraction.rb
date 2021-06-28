# Reduce damage by x percent
class Modifiers::Distraction < Modifiers::Modifier

  self.cleanse = [:all, :distraction]
  self.is_defense = true
  self.is_attack = !self.is_defense
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
  def execute(attributes)
    attributes[:distraction] += @value
  end

  def tick
    puts "before #{self.current_turns}:#{self.current_attacks}"
    super
  end
end
