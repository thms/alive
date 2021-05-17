# Picks from the avaialbe moves ones that are in general better against a speciic class of dinosaurs
class BestAgainstClassStrategy

  BEST_ABILITIES_AGAINST_KLASS = {
    cunning: ['resilient', 'shield', 'precise', 'pounce'],
    cunning_fierce: ['resilient', 'evasive', 'cloak'],
    cunning_resilient: ['resilient'],
    fierce: ['distract', 'cunning', 'evasive', 'cloak', 'dodge'],
    fierce_resilient: [],
    resilient: ['wound', 'shatter'],
    wild_card: []
  }

  def self.next_move(available_abilities)
    defender_klass = :cunning
    # select abilitieis where the name includes at least one word from the array of good optionsname =
    abilities = available_abilities.select {|ability| BEST_ABILITIES_AGAINST_KLASS[defender_klass].map {|kw| ability.class.name.downcase.include? kw}.any?}
    # fallback on random, if nothing matches
    if abilities.empty?
      return available_abilities.sample
    else
      return abilities.first
    end
  end

end
