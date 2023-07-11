local setmetatable = setmetatable
local math_floor = up.math.floor
local pairs = pairs

local mt = {}
mt.__index = mt
mt.type = 'destructable'
up.destructable_class = mt

function mt:__tostring()
    return ('%s|%s'):format('destructable', self:get_name())
end

function mt:get_id()
    return self._base:api_get_id()
end

function mt:get_key()
    return self._base:api_get_key()
end

function mt:get_name()
    return self._base:api_get_str_attr('name')
end

function mt:get_desc()
    return self._base:api_get_str_attr('description')
end

function mt:get_res()
    return self._base:api_get_str_attr('source_nums_cur'):float()
end

function mt:get_model()
    return self._base:api_get_dest_model()
end

function mt:is_alive()
    return self._base.alive
end

function mt:kill()
    self._base:api_kill()
end

function mt:get_point()
    return up.actor_point(self._base:api_get_position())
end

function mt:blink(point)
    self._base:api_transmit(point._base)
end

function mt:remove()
    self._base:api_delete()
end

function mt:reborn(point)
    -- if not point then
    --     point = self:get_point()
    -- end
    self._base:api_revive(point._base)
end

function mt:dry(unit)
    self._base:api_set_dest_dry(unit._base)
end

function mt:set_name(name)
    self._base:api_set_name(name)
end

function mt:hide()
    self._base:api_show_hide(false)
end

function mt:show()
    self._base:api_show_hide(true)
end

function mt:set_hp(hp)
    self._base:api_set_hp(hp)
end

function mt:set_max_hp(hp)
    self._base:api_set_max_hp(hp)
end

function mt:set_size(size)
    self._base:api_set_scale(size)
end

function mt:set_resource(num)
    self._base:api_set_source_num(num)
    self.resource = num
end

function mt:add_resource(value)
    self._base:api_set_source_num(self.resource + value)
end

function mt:set_angle(angle)
    self._base:api_set_face_angle(angle)
end

function mt:in_range()
end

local Des = {}

function up.actor_destructable(d)
    if not d then return end
    local a
    local id
    if type(d) == 'number' then
        a = GameAPI.get_dest_by_id(d)
        id = d
    else
        a = d
        id = d:api_get_id()
    end
    local destructable = {}
    destructable._base = a
    setmetatable(destructable, mt)
    Des[id] = destructable
    return Des[id]
end

function up.create_destructable(name, point, angle, scale)
    local destructable = {}
    if not scale then scale = 1 end
    -- ????????????,???z??*2
    local d = GameAPI.create_destructible(point._base,name,Fix32(angle),Fix32(scale))
    -- local d = GameAPI.create_destructible_new(name, point._base, Fix32(angle), Fix32(scale), Fix32(scale), Fix32(scale), point:get_height())
    -- print(GlobalAPI.get_fixed_coord_index(d:api_get_position(),1):float())
    return up.actor_destructable(d)
end
