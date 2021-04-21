require 'test_helper'

class SimulationTest < ActiveSupport::TestCase

  test "One should win" do
    d1 = Dinosaur.new(health: 3000, damage: 1000, speed: 130, level: 20, name: 'd1', abilities: [Strike, Heal], strategy: DefaultStrategy)
    d2 = Dinosaur.new(health: 3000, damage: 1000, speed: 135, level: 20, name: 'd2', abilities: [Strike], strategy: DefaultStrategy)
    simulation = Simulation.new(d1, d2)
    result = simulation.execute
    # assert_equal 'd1', result
  end
end
