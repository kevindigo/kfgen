class Card
  attr_reader :number
  attr_reader :name
  attr_reader :house
  attr_reader :type
  attr_reader :rarity
  attr_reader :aember
  attr_reader :power
  attr_reader :armor
  attr_reader :traits
  attr_reader :abilities

  def initialize(number, name, house, type, rarity, aember, power, armor, traits, abilities)
    @number = number
    @name = name
    @house = house
    @type = type
    @rarity = rarity
    @aember = aember
    @power = power
    @armor = armor
    @traits = traits
    @abilities = abilities
    @is_maverick = false
  end
  
  def set_maverick
	@is_maverick = true
  end
  
  def maverick?
	return @is_maverick
  end
end
