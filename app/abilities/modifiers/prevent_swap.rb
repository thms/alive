# Prevents from swapping out for a given number of turns
# It's presence is sufficient
class Modifiers::PreventSwap < Modifiers::Modifier

  self.is_defense = true
  self.is_attack = !self.is_defense
  self.destroy = []
  self.cleanse = []
  self.is_positive = true

  def initialize(turns)
    self.turns = turns
    self.attacks = nil
    super()
  end

end
