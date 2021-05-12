require 'test_helper'

class IncreaseCriticalChanceTest < ActiveSupport::TestCase

  test "Critical chance should be increased for one turn" do
    dinosaur = Dinosaur.new(damage: 500, speed: 130, critical_chance: 20, name: 'attacker', abilities: []).reset_attributes!
    dinosaur.add_modifier(Modifiers::IncreaseCriticalChance.new(25))
    # takes effect immediately:
    assert_equal 45, dinosaur.current_attributes[:critical_chance]
    # still active for the next turn:
    dinosaur.tick
    assert_equal 45, dinosaur.current_attributes[:critical_chance]
    # gone for the turn after that:
    dinosaur.tick
    assert_equal 20, dinosaur.current_attributes[:critical_chance]
  end

end
