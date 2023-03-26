require './lib/deckstats'

class DeckLister
  attr_reader :deck
  
  def initialize(deck)
    @deck = deck
  end
  
  def show_cards
    deck.sort!

    deck.cards.each do | card |
      abilities = card.abilities
      abilities.gsub!(/\(.*\)\.?/, '')
      abilities.gsub!("Choose a house on your opponent's identity card.", "Choose an opp house.")
      abilities.gsub!("opponent", 'opp')
      abilities.gsub!("friendly creature", 'friendly')
      abilities.gsub!("enemy creature", 'enemy')
      abilities.gsub!("Forge a key", 'Forge')
      abilities.gsub!("forge a key", 'forge')
      abilities.gsub!("forges a key", 'forges')
      abilities.gsub!("forged a key", 'forged')
      abilities.gsub!("on their next", 'next')
      abilities.gsub!("any number of", '')
      abilities.gsub!("For the remainder of the turn,", 'Rest of turn:')
      abilities.gsub!("draw cards", 'draw')
      abilities.gsub!('This creature gains', 'Gain')
      abilities.gsub!("  ", ' ')
      abilities.gsub!("  ", ' ')
      maverick_flag = card.maverick? ? '*' : ''
      puts "%1.1s%-7s %-1s %-8s %-25s %-70.70s http://aembertree.com/card/core/%s" % 
        [maverick_flag, card.house, card.rarity, card.type, card.name, abilities, card.number]
    end
  
  end
  
  def show_summary
    stats = DeckStats.new(deck)
    
    actions = stats.actions
    artifacts = stats.artifacts
    creatures = stats.creatures
    upgrades = stats.upgrades

    mavericks = deck.cards.count { | card | card.maverick? }
    supers = stats.supers
    rares = stats.rares
    uncommons = stats.uncommons
    commons = stats.commons
      
    aember = stats.aember
    DeckLister::show_summary(actions, artifacts, creatures, upgrades, mavericks, supers, rares, uncommons, commons, aember)
  end
  
  def DeckLister::show_summary(actions, artifacts, creatures, upgrades, mavericks, supers, rares, uncommons, commons, aember)
    # card type and rarity averages from:
    # https://www.reddit.com/r/KeyforgeGame/comments/970a7d/some_analysis_based_on_46_complete_decklists/
    average_actions = 13.28
    average_artifacts = 3.46
    average_creatures = 17.48
    average_upgrades = 1.78
    percent_actions = actions/average_actions*100
    percent_artifacts = artifacts/average_artifacts*100
    percent_creatures = creatures/average_creatures*100
    percent_upgrades = upgrades/average_upgrades*100

    average_maverick = 0.04
    average_rare = 3.24
    average_uncommon = 8.48
    average_common = 24.22
    percent_maverick = mavericks/average_maverick*100
    percent_rare = rares/average_rare*100
    percent_uncommon = uncommons/average_uncommon*100
    percent_common = commons/average_common*100
    
    puts "Actions=%g (%d%%), Artifacts=%g (%d%%), Creatures=%g (%d%%), Upgrades=%g (%d%%)" %
      [actions, percent_actions, artifacts, percent_artifacts, creatures, percent_creatures, upgrades, percent_upgrades]
    puts "Maverick=%g (%d%%), SuperRare=%g, Rare=%g (%d%%), Uncommon=%g (%d%%), Common=%g ... RawAember=%g" %
      [mavericks, percent_maverick, supers, rares, percent_rare, uncommons, percent_uncommon, commons, aember]

  end
end
