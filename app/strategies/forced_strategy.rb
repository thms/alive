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
      'Thoradolosaur' => ['FierceImpact', 'FierceRampage', 'InstantCharge', 'FierceImpact'],
      'Monolorhino'   => ['CunningStrike', 'DefiniteImpact', 'CunningStrike', 'DefiniteImpact'],
      'Erlikospyx'    => ['MinimalSpeedupStrike', 'PrecisePounce', 'RevengeDistractingImpact'],
      'Erlidominus'   => ['MinimalSpeedupStrike', 'Rampage', 'DistractingImpact'],
    }
  end

  def self.one_round(node, attacker, defender)
    result = {value: 0.0, ability_outcomes: attacker.available_abilities.map {|a| [a.class.name, 0.0]}.to_h}
    if @@moves[attacker.name]
      move = @@moves[attacker.name].shift
      if move.nil?
        reset
        move = @@moves[attacker.name].shift
      end
      result[:ability_outcomes][move] = attacker.value
    end
    result
  end

  def self.stats
    {}
  end
end
