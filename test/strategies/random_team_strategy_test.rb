require 'test_helper'

class DefaultTeamStrategyTest < ActiveSupport::TestCase

  test "should select the one of the available dinosaurs" do
    team1 = create_team(1000, 300, 132, 20, 'attacker', [Strike], RandomTeamStrategy)
    team1.reset_attributes!
    name1 = team1.next_dinosaur(nil).name
    name2 = team1.next_dinosaur(nil).name
    assert_not_equal name1, name2
  end

  test "should return the random available ability" do
    team1 = create_team(1000, 300, 132, 20, 'attacker', [Strike, Impact], RandomTeamStrategy)
    team1.reset_attributes!
    stats = {'Strike' => 0, 'Impact' => 0}
    20.times do
      ability = team1.next_move(nil)
      stats[ability.class.name] += 1
    end
    assert_in_delta 10, stats['Strike'], 4
  end

end
