require 'test_helper'

class NullifyingRampageTest < ActiveSupport::TestCase

  test "nullifying rampage should remove defender's positive effects" do
    attacker = Dinosaur.new(damage_26: 100, level: 26, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(health_26: 1000, level: 26, speed: 125, name: 'defender', abilities: []).reset_attributes!
    defender.add_modifier(Modifiers::Shields.new(50, 1, 1))
    NullifyingRampage.new.execute(attacker, defender)
    assert_equal 800, defender.current_health
    assert_equal [], defender.modifiers
  end


end
