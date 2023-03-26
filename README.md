# kfgen
Unofficial deck generator for KeyForge Call of the Archons
Copyright 2018-2019 Kevin B. Smith

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License version 3, as published by
the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

**This is an unofficial work. The trademarks "KeyForge" and "Call of the Archons" remain the property of their rightful owner.**

I wrote this script right when FFG released the first KeyForge set. 
It procedurally generates "random" decks that closely resemble official decks. 
The generater enforces various rules about ratios of common/rare cards, 
ensuring that linked cards both appear in a deck, minimum/maximum counts, etc. 

# Setup
Install ruby (e.g. `sudo apt install ruby-full`)

# Running the application
`cd createdeck`
`ruby create.rb`

The console output will be a list of cards in the generated deck. 
