require './lib/card'

class Deck
  attr_reader :cards
  
  def initialize(cards)
    @cards = cards
  end
  
  def legal?
    if cards.size != 36
      return false
    end
  
    # - Minimum # of copies
      # 282 Routine Job: Minimum x2
    minimum_count_by_card = {282 => 2}
    minimum_count_by_card.each do | number, min |
      count = card_count(number)
      if count > 0 && count < min
        puts "Rejecting due to minimum count of #{number}: #{count} < #{min}"
        return false
      end
    end
    
    # - Maximum # of copies
    ## We have seen as many as 6 of creatures (smaaash and niffle ape), 
    ## so we don't think there is any hard maximum
    ## We have heard that there could be 12 copies (plus mavericks)
    ## We have seen 2 Timetravelers in a deck
    maximum_count_by_card = {
      5 => 1, # Burn the Stockpile
      49 => 1, # Wardrummer
      66 => 1, # Key Hammer
      75 => 1, # Lash of Broken Dreams
      89 => 1, # Master of 1 (but also should limit to a single master of any kind)
      90 => 1, # Master of 2 (but also should limit to a single master of any kind)
      91 => 1, # Master of 3 (but also should limit to a single master of any kind)
      94 => 1, # Restringuntus
      115 => 1, # Library Access
      150 => 1, # Replicator
      192 => 1, # Ether Spider
      248 => 2, # horseman: FFG said they playtested double-horsemen decks
      267 => 1, # Bait and Switch
      325 => 1, # Key Charge
      349 => 1, # Chota Hazri
    }
    maximum_count_by_card.each do | number, max |
      count = card_count(number)
      if count > max
        puts "Rejecting due to maximum count of #{number}: #{count} > #{max}"
        return false
      end
    end
    
    # - Master of X are mutually exclusive with each other
    master_count = 0
    masters = [89, 90, 91]
    masters.each do | number |
      master_count += card_count(number)
    end
    if(master_count > 1)
      puts "Rejecting due to more than one Master of X"
      return false
    end
    
    # - Minimum # of cards with a trait
      # 078 Sacrificial Altar: At least X human creature
      ## There are decks out there with no humans, but Garfield thinks 1 should be the minimum
      ## https://boardgamegeek.com/article/31125385#31125385
      # 219 Honorable Claim: At least X Knight creatures
      # 231 Epic Quest: At least X Knight creatures
      # 235 Round Table: At least X Knight creatures
      # 337 Troop Call: Requires at least X Niffle creature
        # Falstaff "Snap" Iarvia deck only has 1 Niffle
      # 364 Niffle Queen: At least 2 Niffles (plus the Queen)
		# Of 124k registered decks, all Queens have at least 2 apes
    minimum_traits_by_card = {
      78 => {'Human' => 1},
      219 => {'Knight' => 2},
      231 => {'Knight' => 2},
      235 => {'Knight' => 2},
      337 => {'Niffle' => 1},
      364 => {'Niffle' => 3}, # Queen is a Niffle Beast
    }
    minimum_traits_by_card.each do | number, requirements |
      has_trigger_card = has_card(number)
      if has_trigger_card
        requirements.each do | trait, min |
          count = cards.count { | card | card.traits.index(trait) }
          if count < min
            puts "Rejecting due to #{number} minimum trait of #{trait}: #{count} < #{min}"
            return false
          end
        end
      end
    end
    
    # - Minumum number of rares is 2
    puts "Should enforce minimum of 2 rares"
    
    # - Minimum # of creatures within a particular house
      ## 015 Sound the Horns: At least 1 Brobnar creature
      ### The real deck Clementine "Phantom" Verayouth has Sound the Horns with zero brob creatures
      ## 018 Warsong: Requires at least 1 Brobnar creature
      ## 166 Key Abduction: Requires at least X Mars creatures
      ## 171 Mothership Support: At least X Mars creatures
      ## 174 Psychic Network: At least X Mars creatures
      ## 186 Incubation Chamber: Requires at least X Mars creatures
      ## 189 Swap Widget: Requires at least 2 Mars creatures
      ## 190 Blypyp: At least X Mars creatures
      ## 199 Tunk: At least X Mars creatures
      ## 200 Uliq Megamouth: At least X Mars creatures
      ## 203 Yxili Marauder: Requires at least X (2+) Mars creatures
      ## 207 Zyzzix the Many: At least X creatures
      ## 209: Brain Stem Antenna: At least X Mars creatures
      ## 214 Charge!: Requires at least 1 Sanctum creature
        # A real deck had only 2
      ## 277 One Last Job: Requires at least 1 Shadows creature
      ## 323 Full Moon: At least X (1+) Untamed creature
        # A real deck had zero untamed (and no way to play Full Moon off-house
    # Nope
      ## 049 Wardrummer: A real deck had zero other brob creatures
    minimum_house_creatures_by_card = {
#      '015' => {'Brobnar' => 1},
      18 => {'Brobnar' => 1},
      166 => {'Mars' => 2},
      171 => {'Mars' => 2},
      174 => {'Mars' => 2},
      186 => {'Mars' => 2},
      189 => {'Mars' => 2},
      190 => {'Mars' => 2},
      200 => {'Mars' => 2},
      203 => {'Mars' => 2},
      207 => {'Mars' => 2},
      209 => {'Mars' => 2},
      214 => {'Sanctum' => 1},
      277 => {'Shadows' => 1},
      323 => {'Untamed' => 1},
    }
    minimum_house_creatures_by_card.each do | number, requirements |
      has_trigger_card = has_card(number)
      if has_trigger_card
        requirements.each do | house, min |
          count = cards.count { | card | card.house == house && card.type == 'Creature'}
          if count < min
            puts "Rejecting due to #{number} minimum house creatures of #{house}: #{count} < #{min}"
            return false
          end
        end
      end
    end

    # - Minimum # of cards of a type
      # 156 Veylan Analyst: Requires at least 1 artifact
      # 222 Oath of Poverty: Requires at least 1 artifact
      ## A real deck had oath of poverty with none
      # 245 Hayyel the Merchant: Requires at least 1 artifact (ideally more)
      ## A real deck had Hayyel with no artifacts (or ways to control an artifact)
    minimum_type_by_card = {
      156 => {'Artifact' => 1},
      222 => {'Artifact' => 1},
      245 => {'Artifact' => 1},
    }
    minimum_type_by_card.each do | number, requirements |
      has_trigger_card = has_card(number)
      if has_trigger_card
        requirements.each do | type, min |
          count = cards.count { | card | card.type == type}
          if count < min
            puts "Rejecting due to #{number} minimum type of #{type}: #{count} < #{min}"
            return false
          end
        end
      end
    end

    # Include all 4 horsemen 246, 247, 248, 249 (or none at all)
    horsemen = [246,247,248,249]
    if !has_all_or_none(horsemen)
      puts "Rejecting due to an incomplete set of #{horsemen}"
      return false
    end

    # Include both Timetraveler 153 and Help from future self 111 (or neither)
    if !has_all_or_none([111,153])
      puts "Rejecting due to 111 without 153"
      return false
    end
    
    # Bear Flute 340 should add 2 Ancient Bears 345
    ## Real decks have been spotted with just 1 bear
    if has_card(340) && card_count(345) < 1
      puts "Rejecting due to 350 without 345"
      return false
    end
    
    # Niffle Queen 364 should add 2 Niffle Ape 363
		# Of 124k registered decks, all Queens have at least 2 apes
    if has_card(364) && card_count(363) < 2
      puts "Rejecting due to 364 without 363"
      return false
    end
    
    # Faygin 300 should add 1 Urchin 315
    if has_card(300) && card_count(315) < 2
      puts "Rejecting due to 300 without 315"
      return false
    end
    
    # Minimum creatures in deck is 10
    min_creatures = 10
    creature_count = count_by_type['Creature']
    if creature_count < min_creatures
      puts "Not enough creatures #{creature_count} < #{min_creatures}"
      return false
    end
    
    min_creatures_by_house = {
      'Brobnar' => 0, # We have seen a house with 0 brobnar creatures
      'Dis' => 0, # We have seen a house with 1 dis creature
      'Logos' => 0, # We have seen a house with 1 logos creature
      'Mars' => 0, # We have seen a house with 1 mars creature
      'Sanctum' => 0, # We have seen a house with zero sanctum creatures
      'Shadows' => 0, # We have seen a house with 2 shadows creatures
      'Untamed' => 0, # We have seen a house with 1 untamed creature
    }
    
    min_creatures_by_house.each_key do | house |
      min_creatures = min_creatures_by_house[house]
      has_house = cards.index {|card| card.house==house}
      if has_house
        house_creature_count = creature_count_for_house(house)
        if house_creature_count < min_creatures
          puts "Rejecting due to house #{house} with creature count #{house_creature_count} < #{min_creatures}"
          return false
        end
      end
    end
    
    # I don't think there should be minimum action counts per house
    min_actions_per_house = 0
    min_creatures_by_house.each_key do | house |
      if has_house?(house)
        house_action_count = action_count_for_house(house)
        if house_action_count < min_actions_per_house
          puts "Rejecting due to house #{house} with action count #{house_action_count} < #{min_actions_per_house}"
          return false
        end
      end
    end
    
    # Possibly
    
    # Maybe
      ## Any upgrade: At least 1 creature
      ## 177 Soft Landing: At least X Mars creatures+artifacts
      ## 195 "John Smyth": At least X non-agent Mars creatures
      ## 241 Commander Remiel: Requires at least X non-Sanctum creatures
      ## 298 Carlo Phantom: Requires at least 1 artifact? 
        # (a real deck has zero)

    # Unlikely
      ## 148 Ozmo, Martianologist: Maybe require Mars house?
      ## 093 Pitlord: Requires X ways to get rid of it (wipe, return to hand, destroy friendly...)
    
    # No
      ## Max creatures per house: We have seen a Sanctum house with 12 creatures

    # Creature count
      ## 054 Arise!: At least X creatures
      ## 319 Cooperative Hunting: At least X creatures
      ## 017 Unguarded Camp: At least X creatures
      ## 367 Hunting Witch: At least X creatures
      ## 335 Stampede: At least X (3+) creatures
      ## 013 Relentless Assault: At least X (3+) creatures
    
    
    return true
  end
  
  def count_by_type
    counts = {}
    @cards.each do | card |
      type = card.type
      count = counts[type] || 0
      counts[type] = count+1
    end
    return counts
  end

  def sort!
    cards.sort! do | left, right |
		house = left.house <=> right.house
		number = left.number <=> right.number
		house != 0 ? house : number
    end
  end
  
  def has_card(number)
    return card_count(number) > 0
  end
  
  def card_count(number)
    return cards.count {|card| card.number == number}
  end
    
  def has_all_or_none(set_of_numbers)
    count = cards.count {|card| set_of_numbers.index(card.number) }
    return count == 0 || count == set_of_numbers.size
  end
  
  def creature_count_for_house(house)
    return card_type_count_for_house(house, 'Creature')
  end
  
  def action_count_for_house(house)
    return card_type_count_for_house(house, 'Action')
  end
  
  def card_type_count_for_house(house, type)
    count = cards.count do | card |
      card.house == house && card.type == type
    end
    return count
  end
  
  def has_house?(house)
    count = cards.count { |card| card.house == house }
    return count > 0
  end
  
  def mavericks
    cards.count { |card| card.maverick? }
  end
  
end

