require 'test_helper'

class AcuteStunTest < ActiveSupport::TestCase

  # Note: being stunned is reset in the match class at the moment, so for testing it might be better in tick()
  test "Acute stun attack should stun defender for one turn" do
    attacker = Dinosaur.new(damage_26: 500, level: 26, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(health_26: 1000, level: 26, speed: 125, armor: 0, name: 'defender', resistances: [0] * 9, abilities: []).reset_attributes!
    AcuteStun.new.execute(attacker, defender)
    assert_equal true, defender.is_stunned
  end

  test "Acute stun immunity should be effective" do
    attacker = Dinosaur.new(damage_26: 500, level: 26, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(health_26: 1000, level: 26, speed: 125, armor: 50, name: 'defender', resistances: [0,0,0,0,0,100,0,0,0], abilities: []).reset_attributes!
    AcuteStun.new.execute(attacker, defender)
    assert_equal false, defender.is_stunned
  end

  test "Acute stun resistance should be effective" do
    stats = 0
    100.times do
      attacker = Dinosaur.new(damage_26: 500, level: 26, speed: 130, name: 'attacker', abilities: []).reset_attributes!
      defender = Dinosaur.new(health_26: 1000, level: 26, speed: 125, armor: 50, name: 'defender', resistances: [0,0,0,0,0,50,0,0,0], abilities: []).reset_attributes!
      AcuteStun.new.execute(attacker, defender)
      stats += 1 if defender.is_stunned
    end
    assert_in_delta stats, 50, 10
  end

  
  test "Acute stun should target highest damage dino of team" do
    skip # the test makes no sense like this, the stun should excut on the whole team not a selected dinosaur only.
    attacker = Team.new('attacker', ['Dracoceratops']).reset_attributes!
    defender = Team.new('defender', ['Velociraptor', 'Tarbosaurus']).reset_attributes!
    AcuteStun.new.execute(attacker.dinosaurs.first, defender.dinosaurs.first, :raid)
    assert_equal 'Tarbosaurus', defender.dinosaurs.last.name
    assert_equal [false, true], defender.dinosaurs.map(&:is_stunned)
  end
end
