require 'test_helper'

class RendingTest < ActiveSupport::TestCase

  test "Rending attack should reduce defender's health by 40%" do
    attacker = Dinosaur.new(damage_26: 500, level: 26, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(health_26: 1000, level: 26, speed: 125, armor: 0, name: 'defender', resistances: [0] * 9, abilities: []).reset_attributes!
    RendingAttack.new.execute(attacker, defender)
    assert_equal 600, defender.current_health
  end

  test "Rending attack should reduce defender's health by 40% bypassing armor" do
    attacker = Dinosaur.new(damage_26: 500, level: 26, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(health_26: 1000, level: 26, speed: 125, armor: 50, name: 'defender', resistances: [0] * 9, abilities: []).reset_attributes!
    RendingAttack.new.execute(attacker, defender)
    assert_equal 600, defender.current_health
  end

  test "Rending attack should reduce defender's health by 40% bypassing armor and destroy shields" do
    attacker = Dinosaur.new(damage_26: 500, level: 26, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(health_26: 1000, level: 26, speed: 125, armor: 50, name: 'defender', resistances: [0] * 9, abilities: []).reset_attributes!
    defender.add_modifier(Modifiers::Shields.new(100, 2, 2))
    RendingAttack.new.execute(attacker, defender)
    assert_equal 600, defender.current_health
    assert_equal [], defender.modifiers
  end

  test "Immunity to rending attack should not reduce defender's health" do
    attacker = Dinosaur.new(damage_26: 500, level: 26, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(health_26: 1000, level: 26, speed: 125, armor: 50, name: 'defender', resistances: [0,0,0,100,0,0,0,0,0], abilities: []).reset_attributes!
    #defender.add_modifier(Modifiers::Shields.new(100, 2, 2))
    RendingAttack.new.execute(attacker, defender)
    assert_equal 1000, defender.current_health
    #assert_equal [], defender.modifiers
  end


end
