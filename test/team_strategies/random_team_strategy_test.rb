require 'test_helper'

class RandomTeamStrategyTest < ActiveSupport::TestCase

  test "should select one of the available dinosaurs" do
    team1 = create_team(1000, 300, 132, 20, 'attacker', [Strike], [], RandomTeamStrategy)
    team1.reset_attributes!
    name1 = team1.next_dinosaur(nil).name
    name2 = team1.next_dinosaur(nil).name
    assert_not_equal name1, name2
  end

  test "should return a random available ability" do
    team1 = create_team(1000, 300, 132, 20, 'attacker', [Strike, Impact], [], RandomTeamStrategy)
    team1.reset_attributes!
    stats = {'Strike' => 0, 'Impact' => 0, 'SwapIn' => 0}
    20.times do
      ability = team1.next_move(nil)
      stats[ability.class.name] += 1
      # normally this gets recent in the ability, but we are not calling one here:
      team1.recent_dinosaur = nil
    end
    assert_in_delta 10, stats['Strike'], 5
  end

  test "should occasionaly pick a swap in ability" do
    d1 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 130, level: 20, name: 'd1', abilities: [Strike, Impact], abilities_swap_in: [SwapInSavagery], strategy: DefaultStrategy)
    d2 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 125, level: 20, name: 'd2', abilities: [Strike, Impact], strategy: DefaultStrategy)
    team = Team.new('attacker', [d1, d2]).reset_attributes!
    team.strategy = RandomTeamStrategy
    team.current_dinosaur = d2
    stats = {'Strike' => 0, 'Impact' => 0, 'SwapIn' => 0, 'SwapInSavagery' => 0, 'SwapFailed' => 0}
    50.times do
      ability = team.next_move(nil)
      stats[ability.class.name] += 1
      # normally this gets recent in the ability, but we are not calling one here:
      team.recent_dinosaur = nil
    end
    assert_operator stats['SwapInSavagery'], :>, 0
    assert_operator stats['SwapIn'], :>, 0
  end
end
