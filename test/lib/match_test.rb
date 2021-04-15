require 'test_helper'

class MatchTest < ActiveSupport::TestCase

  test "Faster dinosaur should go first" do
    d1 = Dinosaur.new(health: 1000, damage: 100, speed: 130, level: 20, name: 'd1', abilities: [Strike], strategy: DefaultStrategy)
    d2 = Dinosaur.new(health: 1000, damage: 100, speed: 125, level: 20, name: 'd2', abilities: [Strike], strategy: DefaultStrategy)
    match = Match.new(d1, d2)
    result = match.order_dinosaurs
    assert_equal 'd1', result.first.name
  end

  test "Higher level should go first if both are same speed" do
    d1 = Dinosaur.new(health: 1000, damage: 100, speed: 130, level: 20, name: 'd1', abilities: [Strike], strategy: DefaultStrategy)
    d2 = Dinosaur.new(health: 1000, damage: 100, speed: 130, level: 22, name: 'd2', abilities: [Strike], strategy: DefaultStrategy)
    match = Match.new(d1, d2)
    result = match.order_dinosaurs
    assert_equal 'd2', result.first.name
  end

  test "Priority move should go first, if only one has it" do
    d1 = Dinosaur.new(health: 1000, damage: 100, speed: 120, level: 20, name: 'd1', abilities: [Strike], strategy: DefaultStrategy)
    d2 = Dinosaur.new(health: 1000, damage: 100, speed: 120, level: 20, name: 'd2', abilities: [InstantCharge, Strike], strategy: DefaultStrategy)
    match = Match.new(d1, d2)
    result = match.execute
    assert_equal 'd2', result[:winner]
  end

  test "Equal health and damage, faster should win with simple strikes only" do
    d1 = Dinosaur.new(health: 1000, damage: 100, speed: 130, level: 20, name: 'd1', abilities: [Strike], strategy: DefaultStrategy)
    d2 = Dinosaur.new(health: 1000, damage: 100, speed: 125, level: 20, name: 'd2', abilities: [Strike], strategy: DefaultStrategy)
    match = Match.new(d1, d2)
    result = match.execute
    assert_equal "d1", result[:winner]
  end

  test "Equal health and damage, faster should win with simple strikes only - reversed order" do
    d1 = Dinosaur.new(health: 1000, damage: 100, speed: 125, level: 20, name: 'd1', abilities: [Strike], strategy: DefaultStrategy)
    d2 = Dinosaur.new(health: 1000, damage: 100, speed: 130, level: 20, name: 'd2', abilities: [Strike], strategy: DefaultStrategy)
    match = Match.new(d1, d2)
    result = match.execute
    assert_equal "d2", result[:winner]
  end

  test "Equal health and speed, higher damager should win with simple strikes only" do
    d1 = Dinosaur.new(health: 1000, damage: 500, speed: 130, level: 20, name: 'd1', abilities: [Strike], strategy: DefaultStrategy)
    d2 = Dinosaur.new(health: 1000, damage: 100, speed: 130, level: 20, name: 'd2', abilities: [Strike], strategy: DefaultStrategy)
    match = Match.new(d1, d2)
    result = match.execute
    assert_equal "d1", result[:winner]
  end

  test "Equal health, damage, and speed decelerating strike should win " do
    d1 = Dinosaur.new(health: 1000, damage: 100, speed: 130, level: 20, name: 'd1', abilities: [DeceleratingStrike], strategy: DefaultStrategy)
    d2 = Dinosaur.new(health: 1000, damage: 100, speed: 130, level: 20, name: 'd2', abilities: [Strike], strategy: DefaultStrategy)
    match = Match.new(d1, d2)
    result = match.execute
    assert_equal "d1", result[:winner]
  end

  # test "Equal health, damage, and speed decelerating strike against cleansing strike should be a 66/33 percent " do
  #   d1 = Dinosaur.new(health: 1000, damage: 100, speed: 130, level: 20, name: 'd1', abilities: [DeceleratingStrike])
  #   d2 = Dinosaur.new(health: 1000, damage: 100, speed: 130, level: 20, name: 'd2', abilities: [CleansingStrike])
  #   match = Match.new(d1, d2)
  #   result = match.execute
  #   assert_equal "d1", result[:winner]
  # end

end
