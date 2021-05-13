# TODO: implement taunting, when implementeing raids ...
class Modifiers::Taunt < Modifiers::Modifier

  self.is_defense = true
  self.is_attack = !self.is_defense
  self.cleanse = [??]
  self.destroy = []
  self.is_positive = ??

  # API:
  # turns: the number of turns to be active after this current turn ends
  # attacks: the number of attacks
  def initialize(turns, attacks = nil)
    @value = nil
    self.turns = turns
    self.attacks = attacks
    super()
  end

  # Does nothing to the attributes
  def execute(attributes)
  end
end
