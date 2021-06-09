require 'test_helper'

class SimulationTest < ActiveSupport::TestCase

  test "One should win" do
    d1 = Dinosaur.new(health: 3000, damage: 1000, speed: 130, level: 20, name: 'd1', abilities: [Strike, Heal], strategy: DefaultStrategy).reset_attributes!
    d2 = Dinosaur.new(health: 3000, damage: 1000, speed: 135, level: 20, name: 'd2', abilities: [Strike], strategy: DefaultStrategy).reset_attributes!
    simulation = Simulation.new(d1, d2)
    result = simulation.execute
    # assert_equal 'd1', result
  end

  test "wins and losses should be calculated correctly" do
    d1 = Dinosaur.new(health: 3000, damage: 1000, speed: 130, level: 20, name: 'd1', abilities: [Strike, Heal], strategy: DefaultStrategy).reset_attributes!
    d2 = Dinosaur.new(health: 3000, damage: 1000, speed: 135, level: 20, name: 'd2', abilities: [Strike], strategy: DefaultStrategy).reset_attributes!
    simulation = Simulation.new(d1, d2)
    result = simulation.execute
    wins_and_losses = simulation.calc_wins_and_losses(result)
    expected = {"d1"=>{:wins=>0, :losses=>3}, "d2"=>{:wins=>3, :losses=>0}, "draws" => 0}
    assert_equal expected, wins_and_losses
  end


end
