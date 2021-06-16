require 'test_helper'

class DefaultTeamStrategyTest < ActiveSupport::TestCase

  test "should select the first available dinosaur" do
    team1 = create_team(1000, 300, 132, 20, 'attacker', [Strike], [], DefaultTeamStrategy)
    team1.reset_attributes!
    team1.next_dinosaur(nil)
    assert_equal 'attacker-1', team1.current_dinosaur.name
  end

  test "should return the first available ability" do
    team1 = create_team(1000, 300, 132, 20, 'attacker', [Strike, Impact], [], DefaultTeamStrategy)
    team1.reset_attributes!
    ability = team1.next_move(nil)
    assert_equal 'attacker-1', team1.current_dinosaur.name
    assert_equal Strike, ability.class
  end

end
