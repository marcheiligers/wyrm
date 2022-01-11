# Wyrm

Snake reimagined as ... a Dragon. 

Maneuver the Wyrm through the sky, collecting magic coins to open portals which will take you to the next level. With each coin you're one step closer to the end, but you also get longer and faster. Avoid walls and avoid hitting yourself or else you'll have to start over. There are 10 levels. Good luck.

Move with the cursor keys
Hold any key to accelerate
Press P to pause the game
Press M to turn the music on or off
Press S to turns the sound fx on or off

This is my first published game. I wanted to finish something not overly ambitious, but something I could be proud of, with some spit and polish and not just a prototype. I learnt a ton making this game. Pixel art is hard. Bigger pixel art is harder. Music and sound effects too. Everything you add to a game ripples all the way through everything else. And yet there's an amazing, supportive, and friendly community out there, building games, sharing tools and techniques and art. I want to thank all those that helped me, that encouraged me, that gave me feedback on early versions of the game. So now I have finally shipped something. 

This game has been submitted to the [Finally Finish Something 2022](https://itch.io/jam/finally-finish-something-2022) Game Jam. You can play it [in your browser here](https://fascinationworks.itch.io/wyrm).

* Built with [DragonRuby GTK](https://dragonruby.itch.io/dragonruby-gtk)
* [Black Chancery](https://www.1001fonts.com/blackchancery-font.html) font version of 11/19/91 by Earl Allen/Doug Miles
* [7:12 Serif](https://www.1001fonts.com/7-12-serif-font.html) font by "CMunk"
* Chord progression generated with [ChordChord](https://chordchord.com/)
* Melodies generated using [OneMotion Chord Player](https://www.onemotion.com/chord-player/)
* Sound FX generated with [ChipTone](https://sfbgames.itch.io/chiptone) by Tom Vian
* Art created with [Aseprite](https://www.aseprite.org/)

## CHANGELOG

### 1.0.0 - 10 Jan 2022

* Fixed music export, trimmed for loop and converted to ogg
* Improved icon, a little
* Added "hold down" animation
* Changed "gem" to magic coin


### 0.1.7 - 9 Jan 2022

* Added hidden move rate adjustments in Options `[`, `]`, `{`, `}` 
* Redid menu top and corners
* Added icon (needs work)
* Changed morning background color and selection

### 0.1.6 - 8 Jan 2022

* Replaced secondary font text
* Added second page of Help and refactored Wyrm sprites
* Debug off by default and `D` on Options
* Added overlay for pause, game over and win
* Fixed uppause bug when pausing while portal showing

### 0.1.5 - 7 Jan 2022

* Added menu and crash sounds. Changed gem and portal sounds.
* Save options
* Finished off pause

### 0.1.4 - 6 Jan 2022

* Added global music and sound fx keys (M and S)
* Updated music to make it less repetitive
* More art work clean up
* Remove unused files

### 0.1.3 - 5 Jan 2022

* Added music (and mute option)
* Fixed game over not being able to restart bug 
* Added win state

### 0.1.2 - 4 Jan 2022

* Added direction queuing experiment (on by default)
* Added menus for Play, Options (Sound Fx), and Help
* Added Pause, kinda

### 0.1.1 - 3 Jan 2022

* Increased acceleration (/1.5)
* Added sounds for portal, gem and move
* Added framerate for debugging

### 0.1.0 - 2 Jan 2022

* Initial closed test release


## TODO

- [x] Experiment with direction change queueing
- [x] Add pause
- [~] Add sounds
  - [x] Move
  - [x] Portal (maybe change)
  - [x] Gem (maybe change)
  - [ ] Whisp
  - [x] Crash
  - [ ] Win
  - [ ] New level
  - [x] Menu
- [x] Add sound mute
- [~] Add music
- [x] Add music mute
- [x] Add win screen
- [ ] Add credits
- [~] Add menu options
	- [x] Play
	- [x] Options
	- [x] Help
	- [ ] Credits
- [x] Save options
- [ ] Save game on pause
- [~] Icon