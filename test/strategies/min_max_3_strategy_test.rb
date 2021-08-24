require 'test_helper'

class MinMax3StrategyTest < ActiveSupport::TestCase

  test "MinMax Strategy should find strongest move even when there is a clear path to victory as maximising player" do
    #skip
    attacker = Dinosaur.find_by_name('Thoradolosaur').reset_attributes!
    attacker.value = 1.0
    defender = Dinosaur.find_by_name('Velociraptor').reset_attributes!
    defender.value = -1.0
    result = MinMax3Strategy.next_move(attacker, defender)
    assert_includes [GroupShatteringImpact, FierceStrike], result.class
  end

  test "MinMax Strategy should find path to vicory for maximising player" do
    #skip
    attacker = Dinosaur.find_by_name('Thoradolosaur').reset_attributes!
    defender = Dinosaur.find_by_name('Velociraptor').reset_attributes!
    attacker.strategy = MinMax3Strategy
    defender.strategy = MinMax3Strategy
    result = Match.new(attacker, defender).execute
    assert_equal 'Thoradolosaur', result[:outcome]
  end

  test "MinMax Strategy should find path to vicory for minimizing player" do
    #skip
    attacker = Dinosaur.find_by_name('Thoradolosaur').reset_attributes!
    defender = Dinosaur.find_by_name('Velociraptor').reset_attributes!
    attacker.strategy = MinMax3Strategy
    defender.strategy = MinMaxStrategy
    result = Match.new(defender, attacker).execute
    assert_equal 'Thoradolosaur', result[:outcome]
  end

  test "MinMax Strategy should find path to vicory for minimising player quetzorion" do
    #skip
    attacker = Dinosaur.find_by_name('Thoradolosaur').reset_attributes!
    defender = Dinosaur.find_by_name('Quetzorion').reset_attributes!
    attacker.strategy = MinMaxStrategy
    defender.strategy = MinMax3Strategy
    result = Match.new(attacker, defender).execute
    assert_equal 'Thoradolosaur', result[:outcome]
  end

  test "MinMax Strategy should find strongest move when there is a clear path to victory" do
    #skip
    attacker = Dinosaur.find_by_name('Thoradolosaur').reset_attributes!
    defender = Dinosaur.find_by_name('Velociraptor').reset_attributes!
    attacker.value = 1.0
    defender.value = -1.0
    result = MinMax3Strategy.next_move(attacker, defender)
    assert_includes [GroupShatteringImpact, FierceStrike], result.class
  end

  test "MinMax Strategy should find shortest path to vicory for minimising player quetzorion" do
    #skip
    attacker = Dinosaur.find_by_name('Velociraptor').reset_attributes!
    defender = Dinosaur.find_by_name('Quetzorion').reset_attributes!
    attacker.strategy = MinMax3Strategy
    defender.strategy = MinMax3Strategy
    result = Match.new(attacker, defender).execute
    assert_equal 'Quetzorion', result[:outcome]
  end

  test "MinMax Strategy should find shortest path to vicory for minimising player Thoradolosaur" do
    # Thor wins most of the games, only occasionally there are circustances where he looses
    # So expect this test to fail sometimes, re-write to use statistics
    #skip
    attacker = Dinosaur.find_by_name('Thoradolosaur').reset_attributes!
    defender = Dinosaur.find_by_name('Monostegotops').reset_attributes!
    attacker.strategy = MinMax3Strategy
    defender.strategy = MinMax3Strategy
    result = Match.new(attacker, defender).execute
    assert_equal 'Thoradolosaur', result[:outcome]
  end

end
