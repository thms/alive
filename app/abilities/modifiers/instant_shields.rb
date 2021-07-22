# These are working like the normal shields, but they explicitely tick down at the end of the turn, rather than the top of the action
# Used in instant x abilities
class Modifiers::InstantShields < Modifiers::Modifier

  self.tick_when_attacked = true
  self.tick_when_attacking = false
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
