# Really for testing only, force a sequence of moves
class ForcedStrategy < Strategy

  def self.next_move(attacker, defender)
    move = @@moves[attacker.name].shift
    if move.nil?
      attacker.available_abilities.sample
    else
      attacker.available_abilities.select {|a| a.class.name == move}.first
    end
  end

  def self.reset
    @@moves = {
      'Dracoceratops' => ['CleansingImpact', 'FierceImpact'],
      'Suchotator'    => ['LethalWound', 'SuperiorityStrike'],
      'Trykosaurus'   => ['ResilientImpact', 'DefenseShatteringRampage', 'FierceStrike'],
      'Thoradolosaur' => ['FierceImpact', 'GroupShatteringRampage', 'InstantCharge', 'FierceImpact'],
      'Monolorhino'   => ['CunningStrike', 'DefiniteImpact', 'CunningStrike', 'DefiniteImpact']
    }
  end

  def self.stats
    {}
  end
end
