require 'test_helper'

class SimulationStrategyTest < ActiveSupport::TestCase

  test "Simulation Strategy should find strongest move even when there is no guarantee of a win" do
    attacker = Dinosaur.new(
      level: 26,
      health: 4500,
      damage: 1700,
      speed: 105,
      armor: 0,
      critical_chance: 40,
      name: 'Thoradolosaur',
      abilities: [FierceStrike, FierceImpact, GroupShatteringRampage, InstantCharge]).reset_attributes!
    defender = Dinosaur.new(
      level: 26,
      health: 1650,
      damage: 1550,
      speed: 132,
      armor: 0,
      critical_chance: 5,
      name: 'Velociraptor',
      abilities: [Strike, HighPounce]).reset_attributes!

    attacker.color = '#03a9f4'
    defender.color = '#03f4a9'
    result = SimulationStrategy.next_move(attacker, defender)
    assert_equal FierceImpact, result.class
  end

  test "Simulation Strategy should find strongest move when there is a clear path to victory" do
    defender = Dinosaur.new(
      level: 26,
      health: 4500,
      damage: 1700,
      speed: 105,
      armor: 0,
      critical_chance: 40,
      name: 'Thoradolosaur',
      abilities: [FierceStrike, FierceImpact, GroupShatteringRampage, InstantCharge]).reset_attributes!
    attacker = Dinosaur.new(
      level: 26,
      health: 1650,
      damage: 1550,
      speed: 132,
      armor: 0,
      critical_chance: 5,
      name: 'Velociraptor',
      abilities: [Strike, HighPounce]).reset_attributes!

    attacker.color = '#03a9f4'
    defender.color = '#03f4a9'
    result = SimulationStrategy.next_move(attacker, defender)
    assert_equal HighPounce, result.class
  end

end
