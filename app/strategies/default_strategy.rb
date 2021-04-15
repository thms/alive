# Base class for strategies for dinosaurs for pikcng the next ability.
# Possible strategies 1:1
#   Pick first
#   Pick random
#   Maximize damage dealt this round (e.g. pick rampage)
#   Minimize damage received this round (e.g. pick dodge, heal)
#   Protect health
# Possible strategies 4:4
#   Avoid to die - later for team matches
# Input needed:
#   Opponent's health, possible abilities, past abilities (to determine what that might likely do next)
#   Own abilities and their cooldown, etc.
# Picking an ability is limited by what abilities are available at the time, e.g. limited by delay and cooldown
class DefaultStrategy

  def self.next_move(available_abilities)
    available_abilities.first
  end
end
