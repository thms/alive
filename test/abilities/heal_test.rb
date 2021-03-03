require 'test_helper'

class HealTest < ActiveSupport::TestCase

  test "heal should restore health by damage" do
    dinosaur = Dinosaur.new(damage: 100, speed: 130, health: 900, name: 'attacker', abilities: []).reset_attributes!
    dinosaur.current_health = 500
    Heal.new.execute(dinosaur, nil)
    assert_equal 600, dinosaur.current_health
  end

  test "heal should restore health by damage only up to max of attacker's heath" do
    dinosaur = Dinosaur.new(damage: 100, speed: 130, health: 900, name: 'attacker', abilities: []).reset_attributes!
    dinosaur.current_health = 850
    Heal.new.execute(dinosaur, nil)
    assert_equal 900, dinosaur.current_health
  end

end
