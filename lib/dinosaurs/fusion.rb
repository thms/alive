# Provides functionality for fusing dinosaurs and cost of evolution
module Dinosaurs
  module Fusion
    # returns array of all possible hybrids one level up
    def possible_hybrids
      [
        Dinosaur.where(left_id: id),
        Dinosaur.where(right_id: id)
      ].flatten
    end

    # returns names of all possible hybrids one level up
    def possible_hybrid_names
      possible_hybrids.map {|dinosaur| dinosaur.name}.to_sentence
    end

    # True if it has components
    def is_hybrid?
      (left_id && right_id) || (left && right)
    end

    # True if either component is a hybrid
    def is_super_hybrid?
      left.is_hybrid? || right.is_hybrid?
    end

    # Fuse two components up to N times, return the coins spent on the fusions and the number of fusions done
    # update components available DNA
    # checks is fusion is possible
    def fuse(requested_fusions = 1)
      result = {coins: 0, fusions: 0}
      if is_hybrid?
        # level components must be at
        component_target_level = Constants::MIN_LEVEL_OF_COMPONENTS_TO_FUSE[rarity.to_sym]
        # possible fusions:
        left_fusions = (left.dna / Constants::DNA_TO_FUSE[left.rarity.to_sym][self.rarity.to_sym].to_f).floor
        right_fusions = (right.dna / Constants::DNA_TO_FUSE[right.rarity.to_sym][self.rarity.to_sym].to_f).floor
        fusions = [left_fusions, right_fusions].min
        if (left.level < component_target_level) || (right.level < component_target_level) || fusions < 1
          return result
        end
        result[:coins] = fusions * Constants::COINS_TO_FUSE[rarity.to_sym]
        result[:fusions] = fusions
        self.dna += fusions * Constants::FUSION_AVERAGE_DNA
        left.dna -= fusions * Constants::DNA_TO_FUSE[left.rarity.to_sym][self.rarity.to_sym]
        right.dna -= fusions * Constants::DNA_TO_FUSE[right.rarity.to_sym][self.rarity.to_sym]
        return result
      else
        # not a hybrid, nothing to fuse.
        return result
      end
    end

    # Calculate the max level this can be evolved to, given the current DNA and levels of self and components
    def max_level_possible
      coins = 0
      dna_spent = 0
      max_level = self.level
      if is_hybrid?
        # min level components need to be at
        component_target_level = Constants::MIN_LEVEL_OF_COMPONENTS_TO_FUSE[rarity.to_sym]
        # dna needed to get to fusion level left
        if (left.level < component_target_level) && (left.dna_to_level(component_target_level) <= left.dna)
          # bring up to target level - if we have enough DNA
          left.dna -= left.dna_to_level(component_target_level)
          coins += left.coins_to_level(component_target_level)
          left.level = component_target_level
        end
        # now the dino is either at fusion level or not, if he is, calculate the number of fusions he can contribute
        if left.level >= component_target_level
          left_fusions = (left.dna / Constants::DNA_TO_FUSE[left.rarity.to_sym][self.rarity.to_sym].to_f).floor
        end
        # dna needed to get to fusion level right
        if (right.level < component_target_level) && (right.dna_to_level(component_target_level) <= right.dna)
          # bring up to target level - if we have enough DNA
          right.dna -= right.dna_to_level(component_target_level)
          coins += right.coins_to_level(component_target_level)
          right.level = component_target_level
        end
        # now the dino is either at fusion level or not, if he is, calculate the number of fusions he can contribute
        if right.level >= component_target_level
          right_fusions = (right.dna / Constants::DNA_TO_FUSE[right.rarity.to_sym][self.rarity.to_sym].to_f).floor
        end
        # how many fusions can we do:
        fusions = [left_fusions, right_fusions].min
        self.dna += fusions * Constants::FUSION_AVERAGE_DNA
        # how far can we evolve the hybrid?
        while self.dna >= Constants::DNA_TO_EVOLVE[rarity.to_sym][level]
          dna_for_step = Constants::DNA_TO_EVOLVE[rarity.to_sym][level]
          fusions_for_step = (dna_for_step / Constants::FUSION_AVERAGE_DNA.to_f).ceil
          self.dna -= dna_for_step
          # coins for the upgrade:
          coins += coins_to_level(level+1)
          # coins for the fusions used
          coins += fusions_for_step * Constants::COINS_TO_FUSE[rarity.to_sym]
          self.level += 1
        end
        max_level = self.level
      else # non-hybrid
        # iterate until DNA is used up
        dna_available = self.dna
        while Constants::DNA_TO_EVOLVE[rarity.to_sym][max_level] <= dna_available
          dna_available -= Constants::DNA_TO_EVOLVE[rarity.to_sym][max_level]
          dna_spent += Constants::DNA_TO_EVOLVE[rarity.to_sym][max_level]
          max_level += 1
        end
        coins = coins_to_level(max_level)
      end
      return {coins: coins, level: max_level, dna: dna_spent}
    end

    # Calculate the cost to create this recursively at its lowest possible level, including cost for all components
    # dimension is coins, dna
    def cost_to_create(dimension)
      target_level = Constants::STARTING_LEVELS[rarity.to_sym]
      cost_to_level(target_level)[dimension].inject(0) {|s, tuple| tuple[1] > 0 ? s+= tuple[1] : s}
    end

    # Recursion: the leafs are never hybrids, so straight-up
    # hybrids calculate their componets and add the own fusion cost.
    # target_dna: at target level, how much extra DNA needs to be there to allow fusions higher up in the tree?
    def cost_to_level(target_level, target_dna = 0, result = nil)
      # Initialise cost
      result = {
        coins: {},
        dna: {},
        fusions: {},
        target_levels: {}
      } unless result
      # Initialse to zero when not existing
      result[:coins][name] = 0 if result[:coins][name].nil?
      result[:dna][name] = 0 if result[:dna][name].nil?
      result[:fusions][name] = 0 if result[:fusions][name].nil?
      result[:target_levels][name] = target_level
      return result if level == 30
      if is_hybrid?
        # add coins to upgrade self after the fusions are done
        result[:coins][name] += coins_to_level(target_level).to_i

        # Since DNA will be contributed by the two components, this does not require extra DNA / double counting
        result[:dna][name] += 0

        # number of fusions needed to get the hybrid up to the target level plus addiiotnal DNA needed, plus direct cost of fusions
        fusions_needed = (( dna_to_level(target_level) + target_dna - dna)/ Constants::FUSION_AVERAGE_DNA.to_f).ceil
        result[:fusions][name] = fusions_needed
        result[:coins][name] += fusions_needed * Constants::COINS_TO_FUSE[rarity.to_sym]

        # target level for components, and dna each must have in addition to provide the fusions needed
        component_target_level = Constants::MIN_LEVEL_OF_COMPONENTS_TO_FUSE[rarity.to_sym]
        target_dna_left = fusions_needed * Constants::DNA_TO_FUSE[left.rarity.to_sym][rarity.to_sym]
        target_dna_right = fusions_needed * Constants::DNA_TO_FUSE[right.rarity.to_sym][rarity.to_sym]

        # Recursively calculate cost to get the components to the required level with the additional DNA needed for the fusions
        left.cost_to_level(component_target_level, target_dna_left, result)
        right.cost_to_level(component_target_level, target_dna_right, result)

      else
        cost_to_level_non_hybrid(target_level, target_dna, result)
      end
      result
    end

    private

    # Upgrade the dinosaur N levels
    # Only looks at own DNA available, intended as a base operation
    def evolve(requested_levels = 1)
      result = {coins: 0, levels: 0}
      target_level = self.level + requested_levels
      while self.dna >= Constants::DNA_TO_EVOLVE[rarity.to_sym][level] && self.level < target_level
        result[:levels] += 1
        result[:coins] += Constants::COINS_TO_EVOLVE[level]
        self.dna -= Constants::DNA_TO_EVOLVE[rarity.to_sym][level]
        self.level += 1
      end
      result
    end




    # Returns the cost to get to a non-hybrid to a specific level & DNA on hand
    def cost_to_level_non_hybrid(target_level, target_dna, result)
      # Self only.
      result[:coins][name] = coins_to_level(target_level) || 0
      result[:dna][name] = dna_to_level(target_level) + target_dna - dna
      result[:fusions][name] = 0
      result[:target_levels][name] = target_level
    end

    # returns the cost in DNA to reach a given level for this dinosaur, from the current level, only looks at self, not components
    def dna_to_level(target_level)

      if (target_level <= level)
        0 # no cost if we are at target level already
      else
        Constants::DNA_TO_EVOLVE[rarity.to_sym][level .. target_level - 1].inject(:+)
      end
    end

    # returns the cost in coins to reach a given level for this dinosaur, from the current level, only looks at self, not components
    def coins_to_level(target_level)
      # Self only, if the dinsoaur is not yet created, need to skip the levels to the one where it will be created at
      if (target_level <= level)
        0
      elsif level == 0
        start_level = Constants::STARTING_LEVELS[rarity.to_sym]
        Constants::COINS_TO_EVOLVE[start_level .. target_level - 1].inject(:+)
      else
        Constants::COINS_TO_EVOLVE[level .. target_level - 1].inject(:+)
      end
    end

  end
end
