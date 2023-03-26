require 'csv'
require './lib/stricttsv'
require './lib/card'

class CardRating
  attr_reader :number
  attr_reader :rating # -1, 0, 1
  attr_reader :combos # array of other card numbers
  attr_reader :archive # archive, bad archive, anti-archive, wants
  attr_reader :hates # armor, human, scientist, dis, mars, elusive, >=x, <=x, 
  attr_reader :artifacts # many, few, mars
  attr_reader :creatures # many, few, brobnar, logos, mars, mars2, sanctum, knight, untamed, beast
  
  def initialize(number, rating, combos, archive, hates, artifacts, creatures)
    @number = number
    @rating = rating
    @combos = combos
    @archive = archive
    @hates = hates
    @artifacts = artifacts
    @creatures = creatures
  end
end

class DeckRatingStats
  attr_reader :ratings
  attr_reader :deck
  attr_reader :good_archivers
  attr_reader :bad_archivers
  attr_reader :anti_archivers
  attr_reader :creatures
  attr_reader :brobnar_creatures
  attr_reader :dis_creatures
  attr_reader :logos_creatures
  attr_reader :mars_creatures
  attr_reader :sanctum_creatures
  attr_reader :untamed_creatures
  attr_reader :armored_creatures
  attr_reader :elusive_creatures
  attr_reader :human_creatures
  attr_reader :scientist_creatures
  attr_reader :knight_creatures
  attr_reader :beast_creatures
  attr_reader :very_weak_creatures
  attr_reader :weak_creatures
  attr_reader :not_weak_creatures
  attr_reader :artifacts
  attr_reader :mars_artifacts

  def initialize(deck, ratings)
    @ratings = ratings
    @deck = deck
    
    count_by_type = deck.count_by_type
    
    cards = deck.cards
    @good_archivers = cards.count { | card | ratings[card.number].archive=='archiver' }
    @bad_archivers = cards.count { | card | ratings[card.number].archive=='bad archive' }
    @anti_archivers = cards.count { | card | ratings[card.number].archive=='anti-archiver' }

    @creatures = count_by_type['Creature']
    @brobnar_creatures = deck.creature_count_for_house('Brobnar')
    @dis_creatures = deck.creature_count_for_house('Dis')
    @logos_creatures = deck.creature_count_for_house('Logos')
    @mars_creatures = deck.creature_count_for_house('Mars')
    @sanctum_creatures = deck.creature_count_for_house('Sanctum')
    @untamed_creatures = deck.creature_count_for_house('Untamed')
    
    @very_weak_creatures = cards.count { | card | (card.power <= 2) }
    @weak_creatures = cards.count { | card | (card.power <= 3) }
    @not_weak_creatures = cards.count { | card | (card.power > 3) }
    @armored_creatures = cards.count { | card | (card.armor > 0) }

    @human_creatures = cards.count { | card | card.traits.index('Human') }
    @scientist_creatures = cards.count { | card | card.traits.index('Scientist') }
    @knight_creatures = cards.count { | card | card.traits.index('Knight') }
    @beast_creatures = cards.count { | card | card.traits.index('Beast') }
    @elusive_creatures = cards.count { | card | card.abilities.index('Elusive') }
    
    @artifacts = count_by_type['Artifact']
    @mars_artifacts = deck.card_type_count_for_house('Mars', 'Artifact')
  end
  
  def get_archiving
    return good_archivers - bad_archivers - anti_archivers
  end
end

class DeckRater
  attr_reader :ratings
  attr_reader :card_pool
  
  def initialize(ratings_file, card_pool)
    @ratings = {}
    load(ratings_file)
    @card_pool = card_pool
  end
  
  def load(file_name)
    tsv = StrictTsv.new(file_name)
    tsv.parse do |row|
      number = row['Number'].to_i
      rating = row['Rating'].to_i
      combos_as_strings = row['Combos'].split
      combos = combos_as_strings.map {|c| c.to_i}
      archive = row['Archive']
      hates = row['Hates']
      artifacts = row['Artifacts'].strip
      creatures = row['Creatures'].strip
      card_rating = CardRating.new(number, rating, combos, archive, hates, artifacts, creatures)
      @ratings[number] = card_rating
    end
  end

  def rate(deck)
    score = 0
    deck_stats = DeckRatingStats.new(deck, ratings)
    deck.cards.each do | card |
      card_rating = get_rating(deck, deck_stats, card)
      puts "#{card.name}: #{card_rating}"
      score += card_rating
    end
    if(deck_stats.good_archivers > 0)
      score -= deck_stats.bad_archivers * 0.1
      score -= deck_stats.anti_archivers * 0.2
    end
    puts "TOTAL: #{score}"
  end
  
  def get_rating(deck, deck_stats, card)
    score = 0
    raw = ratings[card.number].rating
    score += raw
    combos = get_combos(deck, card)
    score += combos
    archiving = get_archiving(deck, deck_stats, card)
    score += archiving
    hates = get_hates(deck, deck_stats, card)
    score += hates
    artifacts = get_artifacts(deck, deck_stats, card)
    score += artifacts
    creatures = get_creatures(deck, deck_stats, card)
    score += creatures
    return score
  end
  
  def get_combos(deck, card)
    score = 0
    number = card.number
    combos = ratings[number].combos
    combos.each do | combo |
      value = deck.card_count(combo)
      score += value
    end
    return score
  end
  
  def get_archiving(deck, deck_stats, card)
    score = 0
    if(ratings[card.number].archive == 'wants')
      score += deck_stats.get_archiving
    end
    
    if score != 0
      puts "** Archive score #{score}"
    end
    return 0
  end
  
  def get_hates(deck, deck_stats, card)
    score = 0
    hate = ratings[card.number].hates
    if(hate == 'armor')
      score += deck_stats.armored_creatures * -0.2
    end
    if(hate == 'human')
      score += deck_stats.human_creatures * -0.2
    end
    if(hate == 'scientist')
      score += deck_stats.scientist_creatures * -0.2
    end
    if(hate == 'dis')
      score += deck_stats.dis_creatures * -0.2
    end
    if(hate == 'mars')
      score += deck_stats.mars_creatures * -0.2
    end
    if(hate == 'elusive')
      score += deck_stats.elusive_creatures * -0.2
    end
    if(hate == '<=2')
      score += deck_stats.very_weak_creatures * -0.2
    end
    if(hate == '<=3')
      score += deck_stats.weak_creatures * -0.2
    end
    if(hate == '>=3')
      score += deck_stats.not_weak_creatures * -0.2
    end
    
    if score != 0
      puts "** Hate score #{score}"
    end
   return score
  end
  
  def get_artifacts(deck, deck_stats, card)
    score = 0
    artifact_preference = ratings[card.number].artifacts
    artifacts = deck_stats.artifacts
    if(artifact_preference == 'many')
      score += artifacts * 0.4
    end
    if(artifact_preference == 'few')
      score += artifacts * -0.4
    end
    if(artifact_preference == 'mars')
      score += artifacts * 0.2
    end
    
    if score != 0
      puts "** Artifact score #{score}"
    end
    return score
  end
  
  # many, few, brobnar, logos, mars, mars2, sanctum, knight, untamed, beast
  def get_creatures(deck, deck_stats, card)
    score = 0
    creature_preference = ratings[card.number].creatures
    if(creature_preference == 'many')
      score += (deck_stats.creatures-10) * 0.2
    end
    if(creature_preference == 'brobnar')
      score += deck_stats.brobnar_creatures * 0.2
    end
    if(creature_preference == 'logos')
      score += deck_stats.logos_creatures * 0.2
    end
    if(creature_preference == 'mars')
      score += deck_stats.mars_creatures * 0.2
    end
    if(creature_preference == 'mars2')
      score += deck_stats.mars_creatures * 0.4
    end
    if(creature_preference == 'sanctum')
      score += deck_stats.sanctum_creatures * 0.2
    end
    if(creature_preference == 'knight')
      score += deck_stats.knight_creatures * 0.2
    end
    if(creature_preference == 'untamed')
      score += deck_stats.untamed_creatures * 0.2
    end
    if(creature_preference == 'beast')
      score += deck_stats.beast_creatures * 0.2
    end
    if(creature_preference == 'few')
      score += (deck_stats.creatures-10) * -0.2
    end

    if score != 0
      puts "** Creature score #{score}"
    end
    return score
  end
end

