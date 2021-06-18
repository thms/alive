require 'test_helper'

class HealTest < ActiveSupport::TestCase

  test "heal should restore health by damage" do
    dinosaur = Dinosaur.new(damage_26: 100, level: 26, speed: 130, health_26: 900, name: 'attacker', abilities: []).reset_attributes!
    dinosaur.current_health = 500
    Heal.new.execute(dinosaur, nil)
    assert_equal 650, dinosaur.current_health
  end

  test "heal should restore health by damage only up to max of attacker's heath" do
    dinosaur = Dinosaur.new(damage_26: 100, level: 26, speed: 130, health_26: 900, name: 'attacker', abilities: []).reset_attributes!
    dinosaur.current_health = 850
    Heal.new.execute(dinosaur, nil)
    assert_equal 900, dinosaur.current_health
  end

  test "ability with cooldown, should not be availble until cooldown is over" do
    dinosaur = Dinosaur.new(health_26: 1000, damage_26: 100, level: 26, speed: 130, name: 'd1', abilities: [Heal]).reset_attributes!
    assert_equal Heal, dinosaur.available_abilities.first.class
    dinosaur.available_abilities.first.execute(dinosaur, nil)
    dinosaur.tick
    assert_equal [], dinosaur.available_abilities
    dinosaur.tick
    assert_equal [], dinosaur.available_abilities
    dinosaur.tick
    assert_equal [], dinosaur.available_abilities
    dinosaur.tick
    assert_equal Heal, dinosaur.available_abilities.first.class


  end


end
