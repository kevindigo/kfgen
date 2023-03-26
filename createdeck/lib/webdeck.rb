require './lib/deck'

class WebDeckParser
  def initialize(filename)
    @filename = filename
  end
  
  def parse_deck(partial_deck_name)
    File.open(@filename) do |f|
      while !f.eof? do
        skip_header(f)
        deck_name = f.gets.strip
        if deck_name == 'Add To Favorites'
          deck_name = f.gets
        end
        skip_deck_details(f)
        houses = {}
        3.times do 
          house_name, card_numbers = read_house(f)
          houses[house_name] = card_numbers
        end
        skip_footer(f)
        
        if deck_name.index partial_deck_name
          puts "Found #{deck_name}"
        end
      end
    end
  end
  
  def skip_header(f)
    blank = f.gets
    my = f.gets
    if !my.index('My Decks')
      puts "Didn't find header. Got: #{my}"
      exit
    end
    search = f.gets
    organized = f.gets
    avatar = f.gets
    username = f.gets
    blank = f.gets
    if blank.strip.size != 0
      puts "Didn't find blank end of header. Got: #{blank}"
      exit
    end
  end
  
  def skip_deck_details(f)
    10.times do 
      f.gets
    end
  end
  
  def read_house(f)
    house_name = f.gets
    name2 = f.gets
    blank = f.gets
    numbers = []
    12.times do
      card_text = f.gets
      match = card_text.match /.*?(\d{3}).*?/
      card_number = match[1]
      numbers << card_number
    end
    blank = f.gets
    
    return house_name, numbers
  end
  
  def skip_footer(f)
    while true
      line = f.gets
      if line.index('©')
        return
      end
    end
  end
end
