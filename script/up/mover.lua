local math = math
local table = table
local setmetatable = setmetatable
local type = type
local mover_id = 0

local mt = {}
mt.__index = mt

function mt:stop()
    GameAPI.break_unit_mover(self.unit._base)
end

function mt:remove()
    GameAPI.remove_unit_mover(self.unit._base)
end

-- parabola_height 
local function mover_line(data)
    mover_id = mover_id + 1
    local mover = {}
    mover.unit = data.self
    setmetatable(mover, mt)

    local hit_type = {
        ['enemy'] = 0,
        ['ally'] = 1,
        ['all'] = 2,
    }

    local args = pydict()
    args['angle']               = Fix32(data.angle or 0)
    args['max_dist']            = Fix32(data.dis or 99999)
    args['init_velocity']       = Fix32(data.speed or 0)
    args['acceleration']        = Fix32(data.accel or 0)
    args['max_velocity']        = Fix32(data.max_speed or 99999)
    args['min_velocity']        = Fix32(data.min_speed or 0)
    args['init_height']         = Fix32(data.height or 0)
    args['fin_height']          = Fix32(data.target_height or 0)
    args['parabola_height']     = Fix32(data.parabola_height or 0)
    args['collision_type']      = hit_type[data.hit_type] or 0
    args['collision_radius']    = Fix32(data.hit_area or 0.0)
    args['is_face_angle']       = data.is_face or false
    args['is_multi_collision']  = data.is_hit_same or false
    args['terrain_block']       = data.is_block or false
    args['priority']            = data.level or 1    
    args['is_parabola_height']  = data.is_parabola_height or false  
    args['is_absolute_height']  = data.is_absolute_height or false 
    args['is_open_init_height'] = data.is_open_init_height or false 
    args['is_open_fin_height']  = data.is_open_fin_height or false 
    local unit_collide = function()
        if mover.on_hit then
            local hit_target = up.actor_unit(GameAPI.get_mover_collide_unit())
            mover:on_hit(hit_target)
        end
    end
    local mover_finish = function()
        if mover.on_finish then
            mover:on_finish()
        end
    end
    local terrain_collide = function()
        if mover.on_block then
            mover:on_block()
        end
    end
    local mover_interrupt = function()
        if mover.on_break then
            mover:on_finish()
        end
    end
    local mover_removed = function()
        if mover.on_remove then
            mover:on_remove()
        end
    end
    data.self._base.create_mover_trigger(args,'StraightMover',unit_collide,mover_finish,terrain_collide,mover_interrupt,mover_removed)

    return mover
end

function up.effect_class.__index:mover_line(data)
    data.self = self
    return mover_line(data)
end

function up.unit_class.__index:mover_line(data)
    data.self = self
    return mover_line(data)
end

function up.unit_class.__index:stop_mover()
    GameAPI.break_unit_mover(self._base)
end

function up.unit_class.__index:remove_mover()
    GameAPI.remove_unit_mover(self._base)
end
