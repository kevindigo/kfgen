require './lib/card'

class HousePool
  attr_reader :name
  attr_reader :cards
  
  def initialize(name)
    @name = name
    @cards = []
  end
  
  def <<(card)
    @cards << card
  end
  
  def find_by_number(number)
    @cards.each do | card |
      if(card.number == number)
        return card
      end
    end
    return nil
  end
end

class CardPool
  attr_reader :house_pools
  attr_reader :special_pool
  
  def initialize(file_name)
    @house_pools = {}
    @special_pool = {}
    if file_name
      load(file_name)
    end
  end
  
  def load(file_name)
    tsv = StrictTsv.new(file_name)
    tsv.parse do |row|
      number = row['Num'].to_i
      house = row['House']
      num = row['Num']
      name = row['Name']
      type = row['Type']
      rarity = row['Rarity']
      aember = row['Æ'].to_i
      power = row['Power'].to_i
      armor = row['Armor'].to_i
      traits = row['Traits'].split(' * ')
      abilities = row['Abilities']
      card = Card.new(number, name, house, type, rarity, aember, power, armor, traits, abilities)

      self << card
    end
  end
  
  def <<(card)
    if card.rarity == 'S'
      special_pool[card.number] = card
    end
    house_name = card.house
    house_pool = @house_pools[house_name]
    if !house_pool
      house_pool = HousePool.new(house_name)
      @house_pools[house_name] = house_pool
    end
    house_pool << card
  end
  
  def find_by_number(number)
    @house_pools.each_value do | house_pool |
      card = house_pool.find_by_number(number)
      if card
        return card
      end
    end
    
    return nil
  end
end

