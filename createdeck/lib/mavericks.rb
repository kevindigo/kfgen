# Mavericks
## Note that a deck has been posted that has 2 mavericks
## Supposedly there is a 2 maverick per house limit
## See stats above which show that .12% of cards are mavericks
## Of the list below, the surprises are:
## Pitlord has shown up as a maverick, but Garfield said this was a failure
#### https://boardgamegeek.com/article/31125385#31125385
## Neutron Shark can be a maverick (but maybe ony if Logos is in the deck)
## Master of 1 and 3, and Evasion Sigil haven't been seen yet, but the are probably possible

$house_locked = [
  # As of 124k registered decks, these cards have NOT been mavericks
  # Brobnar (4)
  '015', # Sound the Horns
  '023', # Iron Obelisk
  '044', # Rock-Hurling Giant
  '049', # Wardrummer
  # Dis (4)
  '063', # Hecatomb
  '089', # Master of 1
  '091', # Master of 3 (Note that 090 Master of 2 showed up in Brobnar)
  '093', # Pitlord *** has shown up in other houses; maybe only with an escape valve?
  '104', # Truebaru
  # Logos (2)
  '111', # Help from Future Self
  '153', # Timetraveller
  # Mars (17)
  '161', # Battle Fleet
  '164', # Hypnotic Command
  '170', # Mating Season
  '171', # Mothership Support
  '172', # Orbital Bombardment
  '174', # Psychic Network
  '180', # Combat Pheremones
  '181', # Commpod
  '185', # Invasion Portal
  '186', # Incubation Chamber
  '187', # Mothergun
  '189', # Swap Widget
  '190', # Blypyp
  '195', # “John Smyth”
  '203', # Yxili Marauder
  '209', # Brain Stem Antenna
  '211', # Red Planet Ray Gun
  # Sanctum (7)
  '213', # Epic Quest
  '236', # Sigil of Brotherhood
  '246', # Horseman of Death
  '247', # Horseman of Famine
  '248', # Horseman of Pestilence
  '249', # Horseman of War
  '250', # Jehu the Bureaucrat
  # Shadows (5)
  '277', # One Last Job
  '282', # Routine Job
  '286', # Evasion Sigil
  '300', # Faygin
  '313', # Sneklifter
  # Untamed (6)
  '337', # Troop Call
  '340', # Bear Flute
  '343', # Ritual of the Hunt
  '347', # Witch of the Wild
  '354', # Giant Sloth
  '364', # Niffle Queen
]

def can_maverick(card_number)
  return !$house_locked.index(card_number)
end
