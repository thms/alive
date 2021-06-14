require 'test_helper'

class PreventSwapTest < ActiveSupport::TestCase

  test "should prevent from swapping without resistance for given number of turns" do
    attacker = Dinosaur.new(damage: 500, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(health: 1000, speed: 125, name: 'defender', abilities: []).reset_attributes!
    defender.add_modifier(Modifiers::PreventSwap.new(1))
    assert_equal false, defender.can_swap?
    defender.tick
    assert_equal false, defender.can_swap?
    defender.tick
    assert_equal true, defender.can_swap?
  end

  test "should not prevent from swapping with full resistance" do
    attacker = Dinosaur.new(damage: 500, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(health: 1000, speed: 125, name: 'defender', abilities: [], resistances: [0,0,0,0,0,0,100,0,0]).reset_attributes!
    defender.add_modifier(Modifiers::PreventSwap.new(1))
    assert_equal true, defender.can_swap?
  end

  test "should not prevent from swapping with partial resistance" do
    stats = 0
    100.times do
      attacker = Dinosaur.new(damage: 500, speed: 130, name: 'attacker', abilities: []).reset_attributes!
      defender = Dinosaur.new(health: 1000, speed: 125, name: 'defender', abilities: [], resistances: [0,0,0,0,0,0,30,0,0]).reset_attributes!
      defender.add_modifier(Modifiers::PreventSwap.new(1))
      stats += 1 if defender.can_swap?
    end
    assert_in_delta 30, stats, 10
  end

end
