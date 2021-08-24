require 'test_helper'

class TeamMatchTest < ActiveSupport::TestCase

  test "Faster team should win - one" do
    #skip
    team1 = create_team(1000, 300, 132, 20, 'attacker', [Strike], [], DefaultTeamStrategy)
    team2 = create_team(1000, 300, 130, 20, 'defender', [Strike], [], DefaultTeamStrategy)
    match = TeamMatch.new(team1, team2)
    result = match.execute
    assert_equal "attacker", result[:outcome]
  end

  test "Faster team should win - two" do
    #skip
    team1 = create_team(1000, 300, 130, 20, 'attacker', [Strike], [], DefaultTeamStrategy)
    team2 = create_team(1000, 300, 132, 20, 'defender', [Strike], [], DefaultTeamStrategy)
    match = TeamMatch.new(team1, team2)
    result = match.execute
    assert_equal "defender", result[:outcome]
  end

  test "Stronger team should win" do
    #skip
    team1 = create_team(1000, 300, 130, 20, 'attacker', [Strike], [], DefaultTeamStrategy)
    team2 = create_team(1000, 300, 130, 20, 'defender', [Impact], [], DefaultTeamStrategy)
    match = TeamMatch.new(team1, team2)
    result = match.execute
    assert_equal "defender", result[:outcome]
  end

  test "Equal teams with random strategy should be a tossup" do
    #skip
    stats = HashWithIndifferentAccess.new({attacker: 0, defender: 0, draw: 0})
    100.times do
      team1 = create_team(1000, 300, 130, 20, 'attacker', [Strike, Impact], [], RandomTeamStrategy)
      team2 = create_team(1000, 300, 130, 20, 'defender', [Strike, Impact], [], RandomTeamStrategy)
      match = TeamMatch.new(team1, team2)
      result = match.execute
      stats[result[:outcome]] += 1
    end
    assert_in_delta 50, 100* stats[:attacker] / (stats[:attacker] + stats[:defender]), 15
  end

  test "Teams with counter attack should win with default strategy" do
    #skip
    team1 = create_team(1000, 450, 130, 20, 'attacker', [Strike], [MediumCounterAttack], DefaultTeamStrategy)
    team2 = create_team(1000, 450, 130, 20, 'defender', [Strike], [], DefaultTeamStrategy)
    match = TeamMatch.new(team1, team2)
    result = match.execute
    assert_equal "attacker", result[:outcome]
  end


  test "Team match with one player each should work" do
    #skip
    team1 = Team.new('A', ['Geminititan'])
    team1.strategy = DefaultTeamStrategy
    team2 = Team.new('D', ['Thoradolosaur'])
    team2.strategy = DefaultTeamStrategy
    result = TeamMatch.new(team1, team2).execute
  end


end
