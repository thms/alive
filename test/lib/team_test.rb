require 'test_helper'

class TeamTest < ActiveSupport::TestCase

  test "Should pick first dino and ability with default strategy" do
    d1 = Dinosaur.new(health: 1000, damage: 300, speed: 130, level: 20, name: 'd1', abilities: [Strike], strategy: DefaultStrategy)
    d2 = Dinosaur.new(health: 1000, damage: 300, speed: 125, level: 20, name: 'd2', abilities: [Strike], strategy: DefaultStrategy)
    d3 = Dinosaur.new(health: 1000, damage: 300, speed: 125, level: 20, name: 'd3', abilities: [Strike], strategy: DefaultStrategy)
    d4 = Dinosaur.new(health: 1000, damage: 300, speed: 125, level: 20, name: 'd4', abilities: [Strike], strategy: DefaultStrategy)
    team = Team.new('attacker', [d1, d2, d3, d4]).reset_attributes!
    assert_equal 4, team.available_dinosaurs.size
    team.strategy = DefaultTeamStrategy
    team.next_dinosaur(nil)
    assert_equal 'd1', team.current_dinosaur.name
  end

end
