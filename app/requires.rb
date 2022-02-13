PIXEL_MUL = 4
GRID_SIZE = 10 * PIXEL_MUL
GRID_WIDTH = ($args.grid.w / GRID_SIZE).to_i
GRID_HEIGHT = ($args.grid.h / GRID_SIZE).to_i
GRID_CENTER = ($args.grid.w / 2).to_i
GRID_MIDDLE = ($args.grid.h / 2).to_i

MAX_MOVE_TICKS = 30
MIN_MOVE_TICKS = 4

GEMS_PER_LEVEL = 10

require 'app/input_manager.rb'
require 'app/easing.rb'
require 'app/numbers.rb'
require 'app/score_label.rb'
require 'app/cloud.rb'
require 'app/star.rb'
require 'app/whisp.rb'
require 'app/sky.rb'
require 'app/portal.rb'
require 'app/gem.rb'

require 'app/menu_base.rb'
require 'app/hold_anim.rb'
require 'app/direction_keys_anim.rb'
require 'app/menu.rb'

require 'app/game_over.rb'
require 'app/title_bar.rb'
require 'app/map.rb'

require 'app/head_sprite.rb'
require 'app/wings_sprite.rb'
require 'app/body_sprite.rb'

require 'app/body.rb'
require 'app/wyrm.rb'

require 'app/game.rb'
