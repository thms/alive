require 'test_helper'

class NullifyingImpactTest < ActiveSupport::TestCase

  test "nullifyng impact should remove defender's positive effects" do
    attacker = Dinosaur.new(damage: 100, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(health: 1000, speed: 125, name: 'defender', abilities: []).reset_attributes!
    defender.add_modifier(Modifiers::Shields.new(50, 1, 1))
    NullifyingImpact.new.execute(attacker, defender)
    assert_equal 850, defender.current_health
    assert_equal [], defender.modifiers
  end


end
