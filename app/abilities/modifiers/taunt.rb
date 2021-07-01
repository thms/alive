# TODO: implement taunting, when implementeing raids ...
class Modifiers::Taunt < Modifiers::Modifier

  self.tick_when_attacked = true
  self.tick_when_attacking = false
  self.cleanse = []
  self.destroy = []
  self.is_positive = false

  # API:
  # turns: the number of turns to be active after this current turn ends
  # attacks: the number of attacks  ignored
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
