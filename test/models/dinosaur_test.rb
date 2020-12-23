require 'test_helper'
require 'dinosaur'

class DinosaurTest < ActiveSupport::TestCase

  ### non-hybrids ###
  test "cost to create non-hybrid common should 50 DNA and zero coins" do
    dinosaur = Dinosaur.new(level: 0, rarity: 'common', dna: 0, is_hybrid: false, name: 'dinosaur')
    assert_equal 0, dinosaur.cost_to_level(1)[:coins]['dinosaur']
    assert_equal 50, dinosaur.cost_to_level(1)[:dna]['dinosaur']
  end

  test "cost to create non-hybrid rare should 100 DNA and zero coins" do
    dinosaur = Dinosaur.new(level: 0, rarity: 'rare', dna: 0, is_hybrid: false, name: 'dinosaur')
    assert_equal 0, dinosaur.cost_to_level(1)[:coins]['dinosaur']
    assert_equal 100, dinosaur.cost_to_level(6)[:dna]['dinosaur']
  end

  test "coins for non-hybrid to get from level 10 to 11 should be 1000" do
    dinosaur = Dinosaur.new(level: 10, rarity: 'common', dna: 0, is_hybrid: false, name: 'dinosaur')
    assert_equal 1000, dinosaur.cost_to_level(11)[:coins]['dinosaur']
  end

  test "coins for non-hybrid to get from level 0 to 30 should be 1000" do
    dinosaur = Dinosaur.new(level: 0, rarity: 'epic', dna: 0, is_hybrid: false, name: 'dinosaur')
    assert_equal 1305000, dinosaur.cost_to_level(30)[:coins]['dinosaur']
  end

  test "DNA for a common to get from level 10 to 11 should be 1000" do
    dinosaur = Dinosaur.new(level: 10, rarity: 'common', dna: 0, is_hybrid: false, name: 'dinosaur')
    assert_equal 1000, dinosaur.cost_to_level(11)[:dna]['dinosaur']
  end

  test "DNA for a common to get from level 0 to 30 should be 346800" do
    dinosaur = Dinosaur.new(level: 0, rarity: 'common', dna: 0, is_hybrid: false, name: 'dinosaur')
    assert_equal 346800, dinosaur.cost_to_level(30)[:dna]['dinosaur']
  end

  test "DNA for an epic, non-hybrid to get from level 20 to 22 should be 2250" do
    dinosaur = Dinosaur.new(level: 20, rarity: 'epic', dna: 0, is_hybrid: false, name: 'dinosaur')
    assert_equal 2250, dinosaur.cost_to_level(22)[:dna]['dinosaur']
  end

  test "DNA for an epic, non-hybrid with 20 DNA to get from level 20 to 22 should be 2230" do
    dinosaur = Dinosaur.new(level: 20, rarity: 'epic', dna: 20, is_hybrid: false, name: 'dinosaur')
    assert_equal 2230, dinosaur.cost_to_level(22)[:dna]['dinosaur']
  end

  test "DNA for an epic, non-hybrid with 20 DNA to get from level 20 to 22 with 300 additional DNAshould be 2530" do
    dinosaur = Dinosaur.new(level: 20, rarity: 'epic', dna: 20, is_hybrid: false, name: 'dinosaur')
    assert_equal 2530, dinosaur.cost_to_level(22, 300)[:dna]['dinosaur']
  end


  ### fusion ###
  test "Attempting to fuse for a hybrid without sufficient DNA, should not change anything" do
    left = Dinosaur.new(level: 10, rarity: 'rare', dna: 10, is_hybrid: false, name: 'left')
    right = Dinosaur.new(level: 10, rarity: 'common', dna: 0, is_hybrid: false, name: 'right')
    hybrid = Dinosaur.new(level: 12, rarity: 'epic', dna: 0, is_hybrid: true, left: left, right: right, name: 'hybrid')
    result = hybrid.fuse(1)
    assert_equal({coins: 0, fusions: 0}, result)
    assert_equal 10, left.dna
    assert_equal 0, right.dna
    assert_equal 0, hybrid.dna
  end

  test "Attempting to fuse for a hybrid with sufficient DNA, should change all three" do
    left = Dinosaur.new(level: 10, rarity: 'rare', dna: 50, is_hybrid: false, name: 'left')
    right = Dinosaur.new(level: 10, rarity: 'common', dna: 200, is_hybrid: false, name: 'right')
    hybrid = Dinosaur.new(level: 12, rarity: 'epic', dna: 0, is_hybrid: true, left: left, right: right, name: 'hybrid')
    result = hybrid.fuse(1)
    assert_equal({coins: 100, fusions: 1}, result)
    assert_equal 0, left.dna
    assert_equal 0, right.dna
    assert_equal 22, hybrid.dna
  end

  test "Attempting to fuse for a hybrid with sufficient DNA should omly do the possible fusions, should change all three" do
    left = Dinosaur.new(level: 10, rarity: 'rare', dna: 50, is_hybrid: false, name: 'left')
    right = Dinosaur.new(level: 10, rarity: 'common', dna: 200, is_hybrid: false, name: 'right')
    hybrid = Dinosaur.new(level: 12, rarity: 'epic', dna: 0, is_hybrid: true, left: left, right: right, name: 'hybrid')
    result = hybrid.fuse(10)
    assert_equal({coins: 100, fusions: 1}, result)
    assert_equal 0, left.dna
    assert_equal 0, right.dna
    assert_equal 22, hybrid.dna
  end

  ### basic evolution ###
  test "Attempting to evolve a dinosaur without enough DNA should change nothing" do
    dinosaur = Dinosaur.new(level: 10, rarity: 'rare', dna: 50, is_hybrid: false, name: 'left')
    result = dinosaur.evolve(1)
    assert_equal({coins: 0, levels: 0}, result)
    assert_equal dinosaur.level, 10
    assert_equal dinosaur.dna, 50
  end

  test "Attempting to evolve a dinosaur with enough DNA should change it" do
    dinosaur = Dinosaur.new(level: 10, rarity: 'rare', dna: 500, is_hybrid: false, name: 'left')
    result = dinosaur.evolve(1)
    assert_equal({coins: 1000, levels: 1}, result)
    assert_equal 11, dinosaur.level
    assert_equal 200, dinosaur.dna
  end

  test "Attempting to evolve a dinosaur with enough DNA should change it - multiple levels" do
    dinosaur = Dinosaur.new(level: 10, rarity: 'rare', dna: 651, is_hybrid: false, name: 'left')
    result = dinosaur.evolve(5)
    assert_equal({coins: 3000, levels: 2}, result)
    assert_equal 12, dinosaur.level
    assert_equal 1, dinosaur.dna
  end

  ### hybrids ###
  test "Cost for epic hybrid where left and right are ready to fuse" do
    left = Dinosaur.new(level: 10, rarity: 'rare', dna: 10, is_hybrid: false, name: 'left')
    right = Dinosaur.new(level: 10, rarity: 'common', dna: 0, is_hybrid: false, name: 'right')
    hybrid = Dinosaur.new(level: 12, rarity: 'epic', dna: 0, is_hybrid: true, left: left, right: right, name: 'hybrid')
    cost = hybrid.cost_to_level(13)
    assert_equal 4700, cost[:coins]['hybrid']
    assert_equal 0, cost[:coins]['left'] # no coins needed to uplevel to fusion level first.
    assert_equal 0, cost[:coins]['left'] # no coins needed to uplevel to fusion level first.
    assert_equal 0, cost[:dna]['hybrid']
    assert_equal 340, cost[:dna]['left'] # dna needed just for fusions.
    assert_equal 1400, cost[:dna]['right'] # dna needed just for fusions
  end

  test "Cost for epic hybrid where left is ready to fuse and right needs one more level" do
    left = Dinosaur.new(level: 10, rarity: 'rare', dna: 0, is_hybrid: false, name: 'left')
    right = Dinosaur.new(level: 9, rarity: 'common', dna: 0, is_hybrid: false, name: 'right')
    hybrid = Dinosaur.new(level: 12, rarity: 'epic', dna: 0, is_hybrid: true, left: left, right: right, name: 'hybrid')
    cost = hybrid.cost_to_level(13)
    assert_equal 4700, cost[:coins]['hybrid']
    assert_equal 0, cost[:coins]['left'] # no coins needed to uplevel to fusion level first.
    assert_equal 0, cost[:coins]['left'] # no coins needed to uplevel to fusion level first.
    assert_equal 0, cost[:dna]['hybrid']
    assert_equal 350, cost[:dna]['left'] # dna needed just for fusions.
    assert_equal 2150, cost[:dna]['right'] # dna needed for fusions plus moving from level 9 to 10
  end

  test "Cost for epic hybrid with DNA on hand where left is ready to fuse and right needs one more level" do
    left = Dinosaur.new(level: 10, rarity: 'rare', dna: 0, is_hybrid: false, name: 'left')
    right = Dinosaur.new(level: 9, rarity: 'common', dna: 0, is_hybrid: false, name: 'right')
    hybrid = Dinosaur.new(level: 12, rarity: 'epic', dna: 100, is_hybrid: true, left: left, right: right, name: 'hybrid')
    cost = hybrid.cost_to_level(13)
    assert_equal 4300, cost[:coins]['hybrid']
    assert_equal 0, cost[:coins]['left'] # no coins needed to uplevel to fusion level first.
    assert_equal 0, cost[:coins]['left'] # no coins needed to uplevel to fusion level first.
    assert_equal 0, cost[:dna]['hybrid']
    assert_equal 150, cost[:dna]['left'] # dna needed just for fusions.
    assert_equal 1350, cost[:dna]['right'] # dna needed for fusions plus moving from level 9 to 10
  end

  test "Cost for epic hybrid where none of components have any DNA yet" do
    left = Dinosaur.new(level: 0, rarity: 'rare', dna: 0, is_hybrid: false, name: 'left')
    right = Dinosaur.new(level: 0, rarity: 'common', dna: 0, is_hybrid: false, name: 'right')
    hybrid = Dinosaur.new(level: 0, rarity: 'epic', dna: 0, is_hybrid: true, left: left, right: right, name: 'hybrid')
    # getting left to the level 10 where it can be fused with right:
    cost = left.cost_to_level(10)
    assert_equal({:coins=>{"left"=>2000}, :dna=>{"left"=>800}, :fusions=>{"left"=>0}, :target_levels=>{"left"=>10}}, cost)
    # getting right to the level 10 where it can be fused with left:
    cost = right.cost_to_level(10)
    assert_equal({:coins=>{"right"=>2190}, :dna=>{"right"=>3050}, :fusions=>{"right"=>0}, :target_levels=>{"right"=>10}}, cost)
    # getting hybrid to level 20 where it can be fused, includes all the above, too
    cost = hybrid.cost_to_level(20)
    assert_equal( {:coins=>{"hybrid"=>149400, "left"=>2000, "right"=>2190}, :dna=>{"hybrid"=>0, "left"=>8000, "right"=>31850}, :fusions=>{"hybrid"=>144, "left"=>0, "right"=>0}, :target_levels=>{"hybrid"=>20, "left"=>10, "right"=>10}}, cost)
  end


  ### super-hybrids ###
  test "Cost for legendary super hybrid where left and right are ready to fuse" do
    left = Dinosaur.new(level: 10, rarity: 'rare', dna: 0, is_hybrid: false, name: 'left')
    right = Dinosaur.new(level: 10, rarity: 'common', dna: 0, is_hybrid: false, name: 'right')
    hybrid = Dinosaur.new(level: 15, rarity: 'epic', dna: 0, is_hybrid: true, left: left, right: right, name: 'hybrid')
    super_left = Dinosaur.new(level: 15, rarity: 'common', dna: 0, is_hybrid: false, name: 'super_left')
    super_hybrid = Dinosaur.new(level: 16, rarity: 'legendary', dna: 0, is_hybrid: true, left: super_left, right: hybrid, name: 'super_hybrid')
    cost = super_hybrid.cost_to_level(17)
    # super hybrid
    assert_equal 16000, cost[:coins]['super_hybrid']
    assert_equal 0, cost[:dna]['super_hybrid'] # DNA comes from fusions
    # hybrid
    assert_equal 1200, cost[:coins]['hybrid'] # no coins to evolve
    assert_equal 0, cost[:dna]['hybrid'] # five fusions at 50 DNA each, but contributed by left and right ...
    # super left
    assert_equal 0, cost[:coins]['super_left']
    assert_equal 2500, cost[:dna]['super_left'] # five fusions at 500 DNA each
    # left & right
    assert_equal 600, cost[:dna]['left'] #
    assert_equal 2400, cost[:dna]['right']
  end


  test "Cost for unique super hybrid where none of components have any DNA yet" do
    left = Dinosaur.new(level: 0, rarity: 'rare', dna: 0, is_hybrid: false, name: 'left')
    right = Dinosaur.new(level: 0, rarity: 'common', dna: 0, is_hybrid: false, name: 'right')
    hybrid = Dinosaur.new(level: 0, rarity: 'epic', dna: 0, is_hybrid: true, left: left, right: right, name: 'hybrid')
    super_left = Dinosaur.new(level: 0, rarity: 'common', dna: 0, is_hybrid: false, name: 'super_left')
    super_hybrid = Dinosaur.new(level: 0, rarity: 'unique', dna: 0, is_hybrid: true, left: super_left, right: hybrid, name: 'super_hybrid')
    # getting left to the level 10 where it can be fused with right:
    cost = left.cost_to_level(10)
    assert_equal({:coins=>{"left"=>2000}, :dna=>{"left"=>800}, :fusions=>{"left"=>0}, :target_levels=>{"left"=>10}}, cost)
    # getting right to the level 10 where it can be fused with left:
    cost = right.cost_to_level(10)
    assert_equal({:coins=>{"right"=>2190}, :dna=>{"right"=>3050}, :fusions=>{"right"=>0}, :target_levels=>{"right"=>10}}, cost)
    # getting hybrid to level 20 where it can be fused, includes all the above, too
    cost = hybrid.cost_to_level(20)
    assert_equal( {:coins=>{"hybrid"=>149400, "left"=>2000, "right"=>2190}, :dna=>{"hybrid"=>0, "left"=>8000, "right"=>31850}, :fusions=>{"hybrid"=>144, "left"=>0, "right"=>0}, :target_levels=>{"hybrid"=>20, "left"=>10, "right"=>10}}, cost)
    # getting super left to the level 20 where it can be fused with hybrid:
    cost = super_left.cost_to_level(20)
    assert_equal({:coins=>{"super_left"=>138190}, :dna=>{"super_left"=>34300}, :fusions=>{"super_left"=>0}, :target_levels=>{"super_left"=>20}}, cost)
    # gettting super hybrid all the way
    cost = super_hybrid.cost_to_level(21)
    assert_equal 2000, cost[:coins]['left'] # coins from zero to level 10
    assert_equal 2190, cost[:coins]['right'] # coins from zero to level 10
    # assert_equal 0, cost[:coins]['hybrid'] # coins from zero to level 20 + coins for fusion to level 20 + coins for fusions to enough DNA for super
    assert_equal 12, cost[:fusions]['super_hybrid']
  end

  ### Evolving to max level possible ###
  test "Coins and max level possible for non-hybrid without any DNA should be current level and zero coins" do
    dinosaur = Dinosaur.new(level: 10, rarity: 'rare', dna: 0, is_hybrid: false, name: 'dinosaur')
    result = dinosaur.max_level_possible
    assert_equal 0, result[:coins]
    assert_equal 10, result[:level]
  end

  test "Coins and max level possible for non-hybrid with enough DNA for one level" do
    dinosaur = Dinosaur.new(level: 10, rarity: 'rare', dna: 300, is_hybrid: false, name: 'dinosaur')
    result = dinosaur.max_level_possible
    assert_equal 1000, result[:coins]
    assert_equal 11, result[:level]
  end

  test "Coins and max level for a hybrid with only one component having excess DNA should be current level and zero coins" do
    left = Dinosaur.new(level: 10, rarity: 'rare', dna: 0, is_hybrid: false, name: 'left')
    right = Dinosaur.new(level: 10, rarity: 'common', dna: 10000, is_hybrid: false, name: 'right')
    hybrid = Dinosaur.new(level: 11, rarity: 'epic', dna: 0, is_hybrid: true, left: left, right: right, name: 'hybrid')
    result = hybrid.max_level_possible
    assert_equal 0, result[:coins]
    assert_equal 11, result[:level]
  end

  test "Coins and max level for a hybrid with both components having excess DNA should be different" do
    left = Dinosaur.new(level: 10, rarity: 'rare', dna: 250, is_hybrid: false, name: 'left')
    right = Dinosaur.new(level: 10, rarity: 'common', dna: 1000, is_hybrid: false, name: 'right')
    hybrid = Dinosaur.new(level: 11, rarity: 'epic', dna: 0, is_hybrid: true, left: left, right: right, name: 'hybrid')
    result = hybrid.max_level_possible
    assert_equal 2500, result[:coins]
    assert_equal 12, result[:level]
  end

  # # Testing  move_stats
  # test "Available moves should be all before tick if none has a delay" do
  #   dinosaur = Dinosaur.new(health: 1000, damage: 100, speed: 130, name: 'd1', moves: [DeceleratingStrike, Strike])
  #   dinosaur.reset_current_attributes!
  #   assert_equal([DeceleratingStrike, Strike], dinosaur.available_moves)
  # end
  #
  # test "Move is delay of one should only be available after one tick" do
  #   dinosaur = Dinosaur.new(health: 1000, damage: 100, speed: 130, name: 'd1', moves: [Rampage])
  #   dinosaur.reset_current_attributes!
  #   assert_equal([], dinosaur.available_moves)
  #   dinosaur.tick
  #   assert_equal([Rampage], dinosaur.available_moves)
  #   dinosaur.tick
  #   assert_equal([Rampage], dinosaur.available_moves)
  # end
  #
  # test "Using a move with a cooldown, should trigger cooldown" do
  #   d1 = Dinosaur.new(health: 1000, damage: 100, speed: 130, name: 'd1', moves: [Strike])
  #   d2 = Dinosaur.new(health: 1000, damage: 100, speed: 130, name: 'd1', moves: [Rampage])
  #   d1.reset_current_attributes!
  #   d2.reset_current_attributes!
  #   d2.tick
  #   move = d2.available_moves.first.new(d2, d1)
  #   move.execute
  #   d2.tick
  #   assert_equal([], d2.available_moves)
  #   d2.tick
  #   assert_equal([Rampage], d2.available_moves)
  # end

end
