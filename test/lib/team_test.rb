require 'test_helper'

class TeamTest < ActiveSupport::TestCase

  test "Should pick first dino and ability with default strategy" do
    d1 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 130, level: 20, name: 'd1', abilities: [Strike], strategy: DefaultStrategy)
    d2 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 125, level: 20, name: 'd2', abilities: [Strike], strategy: DefaultStrategy)
    d3 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 125, level: 20, name: 'd3', abilities: [Strike], strategy: DefaultStrategy)
    d4 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 125, level: 20, name: 'd4', abilities: [Strike], strategy: DefaultStrategy)
    team = Team.new('attacker', [d1, d2, d3, d4]).reset_attributes!
    assert_equal 4, team.available_dinosaurs.size
    team.strategy = DefaultTeamStrategy
    team.next_dinosaur(nil)
    assert_equal 'd1', team.current_dinosaur.name
  end

  test "should be able to perform swap with two healthy dinos" do
    d1 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 130, level: 20, name: 'd1', abilities: [Strike], abilities_swap_in: [SwapInSavagery], strategy: DefaultStrategy)
    d2 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 125, level: 20, name: 'd2', abilities: [Strike], strategy: DefaultStrategy)
    team = Team.new('attacker', [d1, d2]).reset_attributes!
    team.current_dinosaur = d1
    assert_equal true, team.can_swap?
  end

  test "should not be able to perform swap with only one healthy dino" do
    d1 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 130, level: 20, name: 'd1', abilities: [Strike], strategy: DefaultStrategy)
    d2 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 125, level: 20, name: 'd2', abilities: [Strike], abilities_swap_in: [SwapInSavagery], strategy: DefaultStrategy)
    team = Team.new('attacker', [d1, d2]).reset_attributes!
    team.current_dinosaur = d1
    d2.current_health = 0
    assert_equal false, team.can_swap?
  end

  test "should perform swap with two healthy dinos" do
    d1 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 130, level: 20, name: 'd1', abilities: [Strike], strategy: DefaultStrategy)
    d2 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 125, level: 20, name: 'd2', abilities: [Strike], abilities_swap_in: [SwapInSavagery], strategy: DefaultStrategy)
    team = Team.new('attacker', [d1, d2]).reset_attributes!
    team.current_dinosaur = d1
    team.try_to_swap(d2, d2.available_abilities.first)
    assert_equal 'd2', team.current_dinosaur.name
  end

  test "should return swap-in ability when current dino is healthy" do
    d1 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 130, level: 20, name: 'd1', abilities: [Strike], strategy: DefaultStrategy)
    d2 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 125, level: 20, name: 'd2', abilities: [Strike], abilities_swap_in: [SwapInSavagery], strategy: DefaultStrategy)
    team = Team.new('attacker', [d1, d2]).reset_attributes!
    team.current_dinosaur = d1
    result = team.try_to_swap(d2, d2.available_abilities.first)
    assert_equal SwapInSavagery, result[:ability].class
    assert_equal true, result[:has_swapped]
  end

  test "should return regular ability when current dino is dead" do
    d1 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 130, level: 20, name: 'd1', abilities: [Strike], strategy: DefaultStrategy)
    d2 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 125, level: 20, name: 'd2', abilities: [Strike], abilities_swap_in: [SwapInSavagery], strategy: DefaultStrategy)
    team = Team.new('attacker', [d1, d2]).reset_attributes!
    team.current_dinosaur = d1
    d1.current_health = 0
    result = team.try_to_swap(d2, d2.available_abilities.first)
    assert_equal Strike, result[:ability].class
  end

  test "should return swap failed when current dino is denied swapping out" do
    d1 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 130, level: 20, name: 'd1', abilities: [Strike], strategy: DefaultStrategy)
    d2 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 125, level: 20, name: 'd2', abilities: [Strike], abilities_swap_in: [SwapInSavagery], strategy: DefaultStrategy)
    team = Team.new('attacker', [d1, d2]).reset_attributes!
    team.current_dinosaur = d1
    d1.add_modifier(Modifiers::PreventSwap.new(2, 'self'))
    result = team.try_to_swap(d2, d2.available_abilities.first)
    assert_equal SwapFailed, result[:ability].class
  end

  test "should not turn on revenge for first dino" do
    d1 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 130, level: 20, name: 'd1', abilities: [Strike], strategy: DefaultStrategy)
    d2 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 125, level: 20, name: 'd2', abilities: [Strike, RevengeRampage], abilities_swap_in: [SwapInSavagery], strategy: DefaultStrategy)
    team = Team.new('attacker', [d1, d2]).reset_attributes!
    team.current_dinosaur = d2
    assert_equal false, d2.is_revenge
  end

  test "should turn on revenge for next dino if current one dies" do
    d1 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 130, level: 20, name: 'd1', abilities: [Strike], strategy: DefaultStrategy)
    d2 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 125, level: 20, name: 'd2', abilities: [Strike, RevengeRampage], abilities_swap_in: [SwapInSavagery], strategy: DefaultStrategy)
    team = Team.new('attacker', [d1, d2]).reset_attributes!
    team.current_dinosaur = d1
    team.current_dinosaur.current_health = 0
    team.try_to_swap(d2, d2.abilities.first)
    assert_equal true, d2.is_revenge
  end

  test "should not turn on revenge for next dino if current one is still healthy" do
    d1 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 130, level: 20, name: 'd1', abilities: [Strike], strategy: DefaultStrategy)
    d2 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 125, level: 20, name: 'd2', abilities: [Strike, RevengeRampage], abilities_swap_in: [SwapInSavagery], strategy: DefaultStrategy)
    team = Team.new('attacker', [d1, d2]).reset_attributes!
    team.current_dinosaur = d1
    team.current_dinosaur.current_health = 1
    team.try_to_swap(d2, d2.abilities.first)
    assert_equal false, d2.is_revenge
  end

  test "is_defeated? should not be true for a new, one-dino team" do
    team = Team.new('a', ['Geminititan']).reset_attributes!
    assert_equal false, team.is_defeated?(:pvp)
  end

end
