require 'test_helper'

class ModiferTest < ActiveSupport::TestCase

  test "decrease speed should reduce speed for one round" do
    dinosaur = Dinosaur.new(damage: 100, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    dinosaur.add_modifier(Modifiers::DecreaseSpeed.new(0.1))
    assert_equal 117, dinosaur.current_attributes[:speed]
    dinosaur.tick
    assert_equal 117, dinosaur.current_attributes[:speed]
    dinosaur.tick
    assert_equal 130, dinosaur.current_attributes[:speed]
  end

  test "cleanse should remove the speed reduction" do
    dinosaur = Dinosaur.new(damage: 100, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    dinosaur.add_modifier(Modifiers::DecreaseSpeed.new(0.1))
    dinosaur.cleanse(:all)
    assert_equal 130, dinosaur.current_attributes[:speed]
    assert_empty dinosaur.modifiers
  end

end
