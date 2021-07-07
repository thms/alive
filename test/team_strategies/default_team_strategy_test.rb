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

  test "should swap when the current dino is about to be killed byt the other" do
    team1 = create_team(1000, 300, 132, 26, 'attacker', [Strike, Impact], [], DefaultTeamStrategy)
    team1.reset_attributes!
    team2 = create_team(1000, 300, 132, 26, 'attacker', [Strike, Impact], [], DefaultTeamStrategy)
    team2.reset_attributes!
    team1.current_dinosaur = team1.dinosaurs.first
    team2.current_dinosaur = team2.dinosaurs.first
    team1.current_dinosaur.current_health = 300
    assert_equal true, team1.strategy.should_swap?(team1, team2)
  end

end
