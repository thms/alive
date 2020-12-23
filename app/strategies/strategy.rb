# Base class for strategies for dinosaurs for pikcng the next move.
# Possible strategies 1:1
#   Pick first
#   Pick random
#   Maximize damage dealt this round (e.g. pick rampage)
#   Minimize damage received this round (e.g. pick dodge, heal)
#   Protect health
# Possible strategies 4:4
#   Avoid to die - later for team matches
# Input needed:
#   Opponent's health, possible moves, past moves (to determine what that migh likely do next)
#   Own moves and their cooldown, etc.
# Picking a move is limited by what moves are available at the time, e.g. limited by delay and cooldown
class Strategy
end
