require 'test_helper'

class ReduceCriticalChanceTest < ActiveSupport::TestCase

  test "Critical chance should be decreased for one turn" do
    dinosaur = Dinosaur.new(damage: 500, speed: 130, critical_chance: 40, name: 'defender', abilities: []).reset_attributes!
    dinosaur.add_modifier(Modifiers::ReduceCriticalChance.new(25))
    # takes effect immediately:
    assert_equal 15, dinosaur.current_attributes[:critical_chance]
    # still active for the next turn:
    dinosaur.tick
    assert_equal 15, dinosaur.current_attributes[:critical_chance]
    # gone for the turn after that:
    dinosaur.tick
    assert_equal 40, dinosaur.current_attributes[:critical_chance]
  end

end
