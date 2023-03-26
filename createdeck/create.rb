require './lib/stricttsv'
require './lib/ratings'
require './lib/pool'
require './lib/deck'
require './lib/card'
require './lib/mavericks'
require './lib/lister'

SPECIAL = 'S'
RARE = 'R'
UNCOMMON = 'U'
COMMON = 'C'

MAVERICK_RATIO = 750
LUCKY_NUMBER = 14
SPECIAL_COUNT = 0
RARE_COUNT = 3
UNCOMMON_COUNT = 10
COMMON_COUNT = 28

# Rarity stats
# https://www.reddit.com/r/KeyforgeGame/comments/9xg5b0/data_analysis_rarities_across_13858_decks/
# Total cards: 498888
#    Commons: 329590 (66.06%)
#    Uncommons: 121130 (24.28%)
#    Rares: 46566 (9.33%)
#    Fixed: 1363 (0.27%)
#    Variant: 239 (0.05%)
#    Mavericks: 575 (0.12%)
# This would mean that an "average" deck would have approximately 24 commons, 9 uncommons, and 3 rares.
# (and mavericks appear in 4.32% of decks)

#With 150k decks registered:
# 6 is max copies of niffle ape
# 5 seems to be max for all other commons (there are a ton)
# 5 is also the max for uncommons (just Silent Dagger so far)
# max 3 rares (but a pair of routine jobs and set of horsemen count as 1 each)



class DeckCreator
	COUNT_BY_RARITY = {
	  SPECIAL => SPECIAL_COUNT,
	  RARE => RARE_COUNT,
	  UNCOMMON => UNCOMMON_COUNT,
	  COMMON => COMMON_COUNT,
	  }

  attr_reader :card_pool
  
  def initialize(cards_file)
    @card_pool = CardPool.new('cards.tsv')
  end
  
  def create_deck
    deck = nil
    while !deck || !deck.legal?
      deck = create_candidate_deck
    end
    return deck
  end
  
  def create_candidate_deck
    house_names = choose_houses

    cards = []
    house_names.each do | house_name |
      cards += create_house(house_name)
    end
    
    deck = Deck.new(cards)

    return deck
  end

  def choose_houses
    houses_in_deck = []
    while houses_in_deck.size < 3 do 
      house_name = get_random_house_name
      if !houses_in_deck.index(house_name)
        houses_in_deck << house_name
      end
    end

    return houses_in_deck
  end

  def get_random_house_name
    house_names = Array.new(@card_pool.house_pools.keys)
    house_name = house_names[rand(house_names.size)]
    return house_name
  end
  
  def create_house(house_name)
    available_cards = get_available_cards_for_house(house_name)
    
    house_cards = []
    while house_cards.size < 12 do 
      if insert_maverick?
        maverick = pick_maverick(house_name)
        if !maverick
          next
        end
        cards_to_add = [maverick]
      else
        cards_to_add = pick_card_to_add(available_cards)
      end
      
      house_cards += cards_to_add

      primary_card = cards_to_add[0]
      available_cards = reduce_availability_of(available_cards, primary_card)

      masters = find_masters(house_cards)
      if masters.size > 1
        highest_master = get_highest_master(masters)
        first_high_master = house_cards.index(highest_master)
        house_cards.delete_at(first_high_master)
        puts "2 Masters so removed #{highest_master.name} and kept #{card_names(find_masters(house_cards))}"
      end

    end

    while house_cards.size > 12
      puts "House too large so removing #{house_cards[0].name}"
      house_cards.delete_at(0)
    end

    return house_cards
  end
  
  def insert_maverick?
    return rand(MAVERICK_RATIO) == LUCKY_NUMBER
  end
  
  def pick_maverick(into_house)
    house_name = get_random_house_name
    if house_name == into_house
      puts "Would have been a maverick, but same house"
      return nil
    end
    available_cards = get_available_cards_for_house(house_name)
    cards = pick_card_to_add(available_cards)
    if cards.size != 1
      return nil
    end
    maverick = cards[0]
    puts "Maverick #{maverick.name} from #{house_name} going into #{into_house}"
    if !can_maverick(maverick.number)
      puts " ... but #{maverick.name} is locked, so maverick for this deck"
      return nil
    end
    # TODO: Create a static clone method inside Card
    maverick = Card.new(maverick.number, maverick.name, into_house, 
        maverick.type, maverick.rarity, maverick.aember, 
        maverick.power, maverick.armor, maverick.traits, maverick.abilities)
    maverick.set_maverick
    return maverick
  end
  
  def get_available_cards_for_house(house_name)
    house_pool = @card_pool.house_pools[house_name]
    pool_cards = house_pool.cards
    available_cards = []
    pool_cards.each do | card |
      count = convert_rarity_to_count(card.rarity)
      count.times do
        available_cards << card
      end
    end
    return available_cards
  end
  
  def pick_card_to_add(available_cards)
    pick = rand(available_cards.size)
    card = available_cards[pick]
    
    cards_to_add = []

    # 248 horseman brings in 246, 247, 249 
    if card.number == 248
      cards_to_add = get_horsemen_to_add(card)
    # Timetraveler 153 should bring in Help from future self 111
    elsif card.number == 153
      cards_to_add = get_timetraveler_to_add(card)
    # 089 Master of 1 brings actually brings in one of the 3 Masters
    # (Master of 1 089 or Master of 2 090 or Master of 3 091
    elsif card.number == 89
      cards_to_add = get_master_to_add(card)
    # Niffle Queen 364 should bring in 2 Niffle Ape 363
    ## Of 124k registered decks, all Queens have at least 2 apes
    elsif card.number == 364
      ape_at = available_cards.index {|card| card.number == 363 }
      ape = available_cards[ape_at]
      cards_to_add = get_niffles_to_add(card, ape)
    # Faygin 300 should bring in an Urchin 315
    ## Possibly should be 2 urchins (have never seen fewer)
    elsif card.number == 300
      urchin_at = available_cards.index {|card| card.number == 315 }
      urchin = available_cards[urchin_at]
      cards_to_add = get_urchins_to_add(card, urchin)
    # Routine Job 282 should bring in a second copy
    elsif card.number == 282
      cards_to_add = get_routine_jobs_to_add(card)
    elsif cards_to_add.empty?
      cards_to_add << card
    end
   
    # Bear Flute 340 should bring in 2 Ancient Bears 345
    ## Originally I believed this, but real decks don't always have them
    ## and the flute effect is strong enough to be OK even without bears
    #if card.number == '340'
    #  bear_at = available_cards.index {|card| card.number == '345' }
    #  bear = available_cards[bear_at]
    #  house_cards << bear
    #  house_cards << bear
    #  puts "Added #{bear.name} due to #{card.name}"
    #end
    
    return cards_to_add
  end
  
  def get_horsemen_to_add(first_horseman)
    cards_to_add = [first_horseman]
    other_horseman_numbers = [246, 247, 249]
    other_horseman_numbers.each do | number |
      horse = special_pool[number]
      cards_to_add << horse
      puts "Added #{horse.name} due to #{first_horseman.name}"
    end
    return cards_to_add
  end
  
  def get_timetraveler_to_add(timetraveler)
    cards_to_add = [timetraveler]
    help = special_pool[111]
    cards_to_add << help
    puts "Added #{help.name} due to #{timetraveler.name}"
    return cards_to_add
  end
  
  def get_master_to_add(master)
    which_master = rand(3)
    if which_master == 1
      master2 = special_pool[90]
      master = master2
    elsif which_master == 2
      master3 = special_pool[91]
      master = master3
    end
    puts "Adding #{master.name}"
    cards_to_add = [master]
    return cards_to_add
  end
  
  def find_masters(cards)
    return cards.map {|card| is_master(card) ? card : nil}.compact
  end
  
  def is_master(card)
    return [89,90,91].index(card.number)
  end
  
  def get_highest_master(cards)
    sorted = cards.sort {|a,b| a.number <=> b.number}
    return sorted[-1]
  end
  
  def get_niffles_to_add(queen, ape)
    cards_to_add = [queen]
    cards_to_add << ape
    cards_to_add << ape
    puts "Added #{ape.name}s due to #{queen.name}"
    return cards_to_add
  end
  
  def get_urchins_to_add(faygin, urchin)
    cards_to_add = [faygin, urchin, urchin]
    puts "Added #{cards_to_add.size-1} #{urchin.name}(s) due to #{faygin.name}"
    return cards_to_add
  end

  def get_routine_jobs_to_add(routine_job)
    cards_to_add = [routine_job, routine_job]
    puts "Added 2 copies of #{routine_job.name}"
    return cards_to_add
  end
  
  def convert_rarity_to_count(rarity)
    return COUNT_BY_RARITY[rarity]
  end
  
  def copies_to_cut(rarity, current_count)
    case rarity
      when RARE
        return 1
      when UNCOMMON
        return current_count / 2
      when COMMON
        return current_count / 2
    end
  end
  
  def reduce_availability_of(available_cards, card)
    if [248, 153, 89].index(card.number)
      available_cards.delete(card)
      return available_cards
    end
    
    remaining = available_cards.count { |pool_card| pool_card.number == card.number }
    reduction_factor = (remaining / 3.5).floor
    reduction_factor.times do
      available_cards = remove_one_of(available_cards, card)
    end
    return available_cards
  end
  
  def remove_one_of(available_cards, card)
    at = available_cards.index(card)
    if at
      available_cards.delete_at(at)
    end
    return available_cards
  end
  
  def card_names(cards)
    return cards.collect {|card| card.name}.join
  end
  
  def special_pool
    card_pool.special_pool
  end
end

def create_decks(number)
  $deck_creator = DeckCreator.new('cards.tsv')
  decks = []
  number.times do 
    decks << $deck_creator.create_deck
  end
  return decks
end

def create_and_show_one_deck
  deck = create_decks(1).first
  lister = DeckLister.new(deck)
  lister.show_cards
  lister.show_summary

#  $deck_rater = DeckRater.new('cards-abce.tsv')

end

def show_averages_across_many_decks
  deck_count = 1000
  decks = create_decks(deck_count)
  houses = ['Brobnar', 'Dis', 'Logos', 'Mars', 'Sanctum', 'Shadows', 'Untamed']
  houses.each do | house |
    count = decks.count { |deck| deck.has_house?(house) }
    puts "#{count} #{house}"
  end

  mavericks = 0
  supers = 0
  rares = 0
  uncommons = 0
  commons = 0
  actions = 0
  artifacts = 0
  creatures = 0
  upgrades = 0
  aember = 0
  decks.each do | deck |
    stats = DeckStats.new(deck)
    mavericks += stats.mavericks
    supers += stats.supers
    rares += stats.rares
    uncommons += stats.uncommons
    commons += stats.commons
    actions += stats.actions
    artifacts += stats.artifacts
    creatures += stats.creatures
    upgrades += stats.upgrades
    aember += stats.aember
  end  

  actions = actions.to_f / deck_count
  artifacts = artifacts.to_f / deck_count
  creatures = creatures.to_f / deck_count
  upgrades = upgrades.to_f / deck_count
  mavericks = mavericks.to_f / deck_count
  supers = supers.to_f / deck_count
  rares  = rares.to_f / deck_count
  uncommons = uncommons.to_f / deck_count
  commons = commons.to_f / deck_count
  aember = aember.to_f / deck_count
  DeckLister::show_summary(actions, artifacts, creatures, upgrades, mavericks, supers, rares, uncommons, commons, aember)
end

create_and_show_one_deck
#show_averages_across_many_decks
