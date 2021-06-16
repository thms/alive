require 'test_helper'

class TQTeamStrategyTest < ActiveSupport::TestCase


  test "2:2 better team should win" do
    #skip # This works as expected
    puts 'TQ : Random'
    team1 = ['Tarbosaurus', 'Velociraptor']
    name1 = 'Attacker'
    team2 = ['Allosaurus', 'Dilophosaurus Gen 2']
    name2 = 'Defender'
    stats = HashWithIndifferentAccess.new({name1 => 0, name2 => 0, 'draw' => 0})
    TQTeamStrategy.reset
    1000.times do
      t1 = Team.new(name1, team1)
      t1.strategy = TQTeamStrategy
      t2 = Team.new(name2, team2)
      t2.strategy = TQTeamStrategy
      t1.color = '#03a9f4'
      t2.color = '#03f4a9'
      result = TeamMatch.new(t1, t2).execute
      t1.strategy.learn(result[:outcome_value])
      t2.strategy.learn(result[:outcome_value])
      stats[result[:outcome]] += 1
    end
    puts "Training: #{stats}"
    pp TQTeamStrategy.q_table
    stats = HashWithIndifferentAccess.new({name1 => 0, name2 => 0, 'draw' => 0})
    100.times do
      t1 = Team.new(name1, team1)
      t1.strategy = TQTeamStrategy
      t2 = Team.new(name2, team2)
      t2.strategy = TQTeamStrategy
      t1.color = '#03a9f4'
      t2.color = '#03f4a9'
      result = TeamMatch.new(t1, t2).execute
      t1.strategy.learn(result[:outcome_value])
      stats[result[:outcome]] += 1
    end
    assert_operator stats['Attacker'], :>,  2*stats["Defender"]
    puts "Test: #{stats}"
  end

  test "should learn from a number of games against the random team" do
    skip
    puts 'TQ : Random'
    team1 = ['Thoradolosaur', 'Indoraptor', 'Dracoceratops', 'Suchotator']
    name1 = 'Attacker'
    team2 = ['Trykosaurus', 'Utarinex', 'Magnapyritor', 'Smilonemys']
    name2 = 'Defender'
    stats = HashWithIndifferentAccess.new({name1 => 0, name2 => 0, 'draw' => 0})
    #TQTeamStrategy.reset
    1000.times do
      t1 = Team.new(name1, team1)
      t1.strategy = TQTeamStrategy
      t2 = Team.new(name2, team2)
      t2.strategy = TQTeamStrategy
      t1.color = '#03a9f4'
      t2.color = '#03f4a9'
      result = TeamMatch.new(t1, t2).execute
      t1.strategy.learn(result[:outcome_value])
      t2.strategy.learn(result[:outcome_value])
      stats[result[:outcome]] += 1
    end
    puts "Training: #{stats}"
    #pp TQTeamStrategy.q_table
    stats = HashWithIndifferentAccess.new({name1 => 0, name2 => 0, 'draw' => 0})
    100.times do
      t1 = Team.new(name1, team1)
      t1.strategy = TQTeamStrategy
      t2 = Team.new(name2, team2)
      t2.strategy = TQTeamStrategy
      t1.color = '#03a9f4'
      t2.color = '#03f4a9'
      result = TeamMatch.new(t1, t2).execute
      t1.strategy.learn(result[:outcome_value])
      stats[result[:outcome]] += 1
    end
    puts "Test: #{stats}"
  end
end
