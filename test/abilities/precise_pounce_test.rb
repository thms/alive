require 'test_helper'

class PrecisePounceTest < ActiveSupport::TestCase

  test "Precise rampage should bypass dodge" do
    attacker = Dinosaur.new(damage: 100, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(health: 1000, speed: 125, name: 'defender', abilities: []).reset_attributes!
    defender.add_modifier(Modifiers::Dodge.new(50, 1, 1))
    PrecisePounce.new.execute(attacker, defender)
    assert_equal 800, defender.current_health
    assert_equal 2, defender.modifiers.length
  end
end