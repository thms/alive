require 'test_helper'

class MatchTest < ActiveSupport::TestCase

  test "Equal health and damage, faster should win with simple strikes only" do
    d1 = Dinosaur.new(health: 1000, damage: 100, speed: 130, name: 'd1', moves: [Strike])
    d2 = Dinosaur.new(health: 1000, damage: 100, speed: 125, name: 'd2', moves: [Strike])
    match = Match.new(d1, d2)
    result = match.execute
    assert_equal "d1 wins", result
  end

  test "Equal health and damage, faster should win with simple strikes only - reversed order" do
    d1 = Dinosaur.new(health: 1000, damage: 100, speed: 125, name: 'd1', moves: [Strike])
    d2 = Dinosaur.new(health: 1000, damage: 100, speed: 130, name: 'd2', moves: [Strike])
    match = Match.new(d1, d2)
    result = match.execute
    assert_equal "d2 wins", result
  end

  test "Equal health and speed, higher damager should win with simple strikes only" do
    d1 = Dinosaur.new(health: 1000, damage: 500, speed: 130, name: 'd1', moves: [Strike])
    d2 = Dinosaur.new(health: 1000, damage: 100, speed: 130, name: 'd2', moves: [Strike])
    match = Match.new(d1, d2)
    result = match.execute
    assert_equal "d1 wins", result
  end

  test "Equal health, damage, and speed decelerating stirke should win " do
    d1 = Dinosaur.new(health: 1000, damage: 100, speed: 130, name: 'd1', moves: [DeceleratingStrike])
    d2 = Dinosaur.new(health: 1000, damage: 100, speed: 130, name: 'd2', moves: [Strike])
    match = Match.new(d1, d2)
    result = match.execute
    assert_equal "d1 wins", result
  end

end
