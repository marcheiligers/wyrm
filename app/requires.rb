PIXEL_MUL = 4
GRID_SIZE = 10 * PIXEL_MUL
GRID_WIDTH = ($gtk.args.grid.w / GRID_SIZE).to_i
GRID_HEIGHT = ($gtk.args.grid.h / GRID_SIZE).to_i
GRID_CENTER = ($gtk.args.grid.w / 2).to_i
GRID_MIDDLE = ($gtk.args.grid.h / 2).to_i

require 'app/easing.rb'
require 'app/numbers.rb'
require 'app/fruit_score_label.rb'
require 'app/cloud.rb'
require 'app/star.rb'
require 'app/whisp.rb'
require 'app/sky.rb'
require 'app/portal.rb'
require 'app/gem.rb'
require 'app/menu.rb'
require 'app/title_bar.rb'
require 'app/map.rb'
require 'app/body.rb'
require 'app/wings.rb'
require 'app/wyrm.rb'
require 'app/game.rb'
