require 'test_helper'

class BossTeamTest < ActiveSupport::TestCase

  test "Should populate boss and inflate if no minions provided" do
    team = BossTeam.new('defender', 'Bajadasaurus Boss', []).reset_attributes!
    assert_equal Boss, team.boss.class
    assert_equal [], team.minions
  end

  test "Should populate boss and minions and inflate if minions provided" do
    team = BossTeam.new('defender', 'Bajadasaurus Boss', []).reset_attributes!
    assert_equal Boss, team.boss.class
    assert_equal [], team.minions
  end

end
