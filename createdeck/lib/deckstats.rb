require './lib/deck'

class DeckStats
  def initialize(deck)
    @deck = deck
  end
  
  def cards
    @deck.cards
  end
  
  def aember
    cards.sum { |card| card.aember }
  end
  
  def actions
    cards.count { |card| card.type == 'Action' }
  end
  
  def artifacts
    cards.count { |card| card.type == 'Artifact' }
  end
  
  def creatures
    cards.count { |card| card.type == 'Creature' }
  end
  
  def upgrades
    cards.count { |card| card.type == 'Upgrade' }
  end
  
  def mavericks
    cards.count { |card| card.maverick? }
  end
  
  def supers
    cards.count { |card| card.rarity == 'S' }
  end
  
  def rares
    cards.count { |card| card.rarity == 'R' }
  end
  
  def uncommons
    cards.count { |card| card.rarity == 'U' }
  end
  
  def commons
    cards.count { |card| card.rarity == 'C' }
  end
  
end
