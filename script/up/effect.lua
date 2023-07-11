local setmetatable = setmetatable
local ipairs = ipairs

local mt = {}
mt.__index = mt
mt.type = 'effect'
mt.show = true
mt.id = nil
mt.rotate = {0,0,0}
mt.scale = {1,1,1}
mt.ani_speed = 1
up.effect_class = mt


function mt:get_id()
    return self._base:api_get_key()
end


function mt:owner()
    return up.actor_unit(self._base:api_get_owner())
end


function mt:remove()
    self._base:api_delete()
end


function mt:set_point(point)
    self._base:api_set_position(point._base)
end


function mt:set_facing(facing)
    self._base:api_set_face_angle(facing)
end


function mt:set_rotate(data)
    if data.x then self.rotate[1] = data.x end
    if data.y then self.rotate[2] = data.y end
    if data.z then self.rotate[3] = data.z end
    self._base:api_set_rotation(self.rotate[1],self.rotate[2],self.rotate[3])
end

function mt:set_scale(data)
    if data.x then self.scale[1] = data.x end
    if data.y then self.scale[2] = data.y end
    if data.z then self.scale[3] = data.z end
    self._base:api_set_scale(self.scale[1],self.scale[2],self.scale[3])
end


function mt:set_ani_speed(speed)
    self._base:api_set_animation_speed(Fix32(speed))
    self.ani_speed = speed
end


function mt:set_life(life)
    self._base:api_set_duration(Fix32(life))
end


function mt:add_life(life)
    self._base:api_add_duration(Fix32(life))
end


function mt:get_life()
    return self._base:api_get_left_time()
end


function mt:get_height()
    return self._base:api_get_height()
end


function mt:get_point()
    return up.actor_point(self._base:api_get_position())
end


function mt:get_facing()
    return self._base:api_get_face_dir()
end


function mt:get_rotate()
    return self.rotate
end


function mt:get_scale()
    return self.scale
end


function mt:get_ani_speed()
    return self.ani_speed
end



function up.unit_class.__index.add_effect(self,data)
    local effect = {}
    if not data.angle then data.angle = 0 end
    data.angle = Fix32(data.angle)
    if not data.target then data.target = self end
    if not data.socket then data.socket = 'origin' end
    if data.target then data.target = data.target._base end
    if data.skill then data.skill = data.skill._base end
    effect._base = GameAPI.create_projectile_on_socket(data.id, self._base, data.socket, data.angle, data.target, data.skill, 1)
    setmetatable(effect, mt)
    if data.life then
        effect:set_life(data.life)
    end
    return effect
end


function up.effect(data)
    local effect = {}
    if not data.angle then data.angle = 0 end
    data.angle = Fix32(data.angle)
    if data.owner then data.owner = data.owner._base end
    if data.skill then data.skill = data.skill._base end
    local is_life = false
    if data.life then is_life = true end
    effect._base = GameAPI.create_projectile_in_scene(
        data.id,
        data.point._base,
        data.angle,
        data.owner,
        data.skill,
        data.life,
        is_life,
        data.height or 0,
        data.visible_type or 1
    )
    setmetatable(effect, mt)
    return effect
end
