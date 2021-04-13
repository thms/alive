# Modifiers

## Storage
These are stored as active modifiers with the dinosaur that they impact.
Each modifier affects one thing only, one ability can have many modifiers that impact both dinosaurs

## Expiry
"lasting N turns" - these get expired by tick()
"for M attacks" - these get expired by attack()
Keeping track: either with the same mechanism as abilities - ability_stats, or we instantiate the things and they keep tack of if themselves.

## Calculating current attributes
Modifiers act as a chain on the attributes to calculate the current attributes:
dino.attributes | mod | mod | mod | mod ==> current_attributes

## Dealing with probability
When evaluating a modifier, use a random toss to determine if it is applied

## Dealing with immunity / resistance
Immunity: don't add to list of active Modifiers
Resistance: evaluate probability at chain evaluation, and skip if resisted

## Cleanse Mechanism
This removes some detrimental modifiers, but not all, e.g. cleanse distraction
It is part of an ability, so affects the stack of active modifiers at the beginning of the ability


## All modifiers
### Distraction / Reduced damage
Target: other
Mechanism: cumulative percentages
current_damage = original_damage * (100 - SUM(distraction))/100
DOING

### Decrease Speed
Target: other
Mechanism: cumulative percentages
current_speed = original_speed * (100 + SUM(increase) - Sum(decrease))/100
DONE

### Increase Speed
Mechanism: cumulative percentages
current_speed = original_speed * (100 + SUM(increase) - Sum(decrease))/100
Target: self
DONE

### Shields
Mechanism: cumulative percentages
total_shields = sum(shields)
Damage = original_damage * (100 - total_shields)/100
DONE

Dodge x % of damage

Increase attacks

Increase critical chance

Reduce critical chance




------
Remove damage Increase

Remove critical Increase

Remove cloak, dodge and Shields
