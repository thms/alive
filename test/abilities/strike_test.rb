require 'test_helper'

class StrikeTest < ActiveSupport::TestCase

  test "strike should reduce defender's health by attacker's damage" do
    attacker = Dinosaur.new(damage: 100, speed: 130, name: 'attacker', abilities: [Strike]).reset_attributes!
    defender = Dinosaur.new(health: 1000, speed: 125, name: 'defender', abilities: [Strike]).reset_attributes!
    Strike.new(attacker, defender).execute
    assert_equal 900, defender.current_health
  end

  test "strike to_s should print amount of damage dealt on defender" do
    attacker = Dinosaur.new(damage: 100, level: 10, rarity: 'common', dna: 0, name: 'attacker', abilities: [Strike]).reset_attributes!
    defender = Dinosaur.new(health: 1000, level: 10, rarity: 'common', dna: 0, name: 'defender', abilities: [Strike]).reset_attributes!
    assert_equal "attacker Strike damage 100 on health 1000", Strike.new(attacker, defender).to_s

  end
end
