up = {}

function up.print(...)
	local str = ''
    local t = {...}
    for i = 1, #t - 1 do
        str = str .. tostring(t[i]) .. '    '
    end
    str = str .. tostring(t[#t])
	GameAPI.print_to_dialog(3,str)
end
print = up.print

require 'up.keyboard'
require 'up.constant'
require 'up.game'
require 'up.util'
require 'up.math'
require 'up.timer'
require 'up.point'
require 'up.trigger'
require 'up.event'
require 'up.player'
require 'up.unit'
require 'up.skill'
require 'up.buff'
require 'up.effect'
require 'up.particle'
require 'up.lightning'
require 'up.destructable'
require 'up.item'
require 'up.ui'
require 'up.selector'
require 'up.order'
require 'up.mover'
require 'up.tech'
require 'up.precondition'
require("up.area")

--=======EG=======--
require("up.team")