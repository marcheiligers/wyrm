PIXEL_MUL = 4
GRID_SIZE = 10 * PIXEL_MUL
GRID_WIDTH = ($args.grid.w / GRID_SIZE).to_i
GRID_HEIGHT = ($args.grid.h / GRID_SIZE).to_i
GRID_CENTER = ($args.grid.w / 2).to_i
GRID_MIDDLE = ($args.grid.h / 2).to_i

MAX_MOVE_TICKS = 30
MIN_MOVE_TICKS = 4

COINS_PER_LEVEL = 10

# require 'lib/all.rb'
require 'app/lib/uiex/concerns/forwardable.rb'
require 'app/lib/uiex/concerns/focusable.rb'
require 'app/lib/uiex/concerns/hoverable.rb'
require 'app/lib/uiex/concerns/draggable.rb'
require 'app/lib/uiex/concerns/easing.rb'
require 'app/lib/uiex/concerns/color.rb'
require 'app/lib/uiex/concerns/observable.rb'
require 'app/lib/uiex/concerns/input_helpers.rb'

require 'app/lib/uiex/window.rb'
require 'app/lib/uiex/image.rb'
require 'app/lib/uiex/reveal.rb'
require 'app/lib/uiex/button.rb'
# require 'app/lib/uiex/horizontal_rule.rb'
require 'app/lib/uiex/focus_rect.rb'
require 'app/lib/uiex/vertical_menu.rb'
# require 'app/lib/uiex/slider.rb'


require 'app/easing.rb'
require 'app/numbers.rb'
require 'app/score_label.rb'
require 'app/cloud.rb'
require 'app/star.rb'
require 'app/whisp.rb'
require 'app/sky.rb'
require 'app/portal.rb'
require 'app/coin.rb'

require 'app/hold_anim.rb'
require 'app/direction_keys_anim.rb'

require 'app/game_over.rb'
require 'app/title_bar.rb'
require 'app/map.rb'

require 'app/head_sprite.rb'
require 'app/wings_sprite.rb'
require 'app/body_sprite.rb'

require 'app/body.rb'
require 'app/wyrm.rb'

require 'app/ui/main_menu.rb'

require 'app/game.rb'
