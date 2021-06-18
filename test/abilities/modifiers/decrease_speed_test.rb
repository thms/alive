require 'test_helper'

class DecreaseSpeedTest < ActiveSupport::TestCase

  test "decrease speed should reduce speed for one turn" do
    dinosaur = Dinosaur.new(damage_26: 100, level: 26, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    dinosaur.add_modifier(Modifiers::DecreaseSpeed.new(10, 1, 1))
    # should change speed now
    assert_equal 117, dinosaur.current_speed
    # should be effective in the next turn
    dinosaur.tick
    assert_equal 117, dinosaur.current_speed
    # should be back to noral in the turn after
    dinosaur.tick
    assert_equal 130, dinosaur.current_speed
  end

  test "cleanse should remove the speed reduction" do
    dinosaur = Dinosaur.new(damage_26: 100, level: 26, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    dinosaur.add_modifier(Modifiers::DecreaseSpeed.new(10, 1, 1))
    dinosaur.cleanse(:all)
    assert_equal 130, dinosaur.current_speed
    assert_empty dinosaur.modifiers
  end

end
