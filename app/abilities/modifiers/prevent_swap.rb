# Prevents from swapping out for a given number of turns
# It's presence is sufficient
class Modifiers::PreventSwap < Modifiers::Modifier

  self.is_defense = true
  self.is_attack = !self.is_defense
  self.destroy = []
  self.cleanse = []
  self.is_positive = false

  def initialize(turns, source)
    self.turns = turns + 1
    self.attacks = nil
    self.source = source
    super()
  end

end
