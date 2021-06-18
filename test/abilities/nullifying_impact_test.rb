require 'test_helper'

class NullifyingImpactTest < ActiveSupport::TestCase

  test "nullifyng impact should remove defender's positive effects" do
    attacker = Dinosaur.new(damage_26: 100, level: 26, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(health_26: 1000, level: 26, speed: 125, name: 'defender', abilities: []).reset_attributes!
    defender.add_modifier(Modifiers::Shields.new(50, 1, 1))
    NullifyingImpact.new.execute(attacker, defender)
    assert_equal 850, defender.current_health
    assert_equal [], defender.modifiers
  end


end
