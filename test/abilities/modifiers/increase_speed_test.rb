require 'test_helper'

class IncreaseSpeedTest < ActiveSupport::TestCase

  test "increase speed should increase speed for one turn" do
    dinosaur = Dinosaur.new(damage_26: 100, level: 26, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    dinosaur.add_modifier(Modifiers::IncreaseSpeed.new(10, 1, 1))
    # should change speed now
    assert_equal 143, dinosaur.current_speed
    # should be effective in the next turn
    dinosaur.tick
    assert_equal 143, dinosaur.current_speed
    # should be back to noral in the turn after
    dinosaur.tick
    assert_equal 130, dinosaur.current_speed
  end

  test "nullify should remove the speed increase" do
    dinosaur = Dinosaur.new(damage_26: 100, level: 26, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    dinosaur.add_modifier(Modifiers::IncreaseSpeed.new(10, 1, 1))
    dinosaur.nullify
    assert_equal 130, dinosaur.current_speed
    assert_empty dinosaur.modifiers
  end

  test "cleanse should not remove the speed increase" do
    dinosaur = Dinosaur.new(damage_26: 100, level: 26, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    dinosaur.add_modifier(Modifiers::IncreaseSpeed.new(10, 1, 1))
    dinosaur.cleanse(:all)
    assert_equal 143, dinosaur.current_speed
  end

end
