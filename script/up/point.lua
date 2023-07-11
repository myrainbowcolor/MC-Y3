local math = math
local table = table
local setmetatable = setmetatable
local type = type

local mt = {}
--class
mt.__index = mt
--type
mt.type = 'point'
--position
mt.x = 0
mt.y = 0
mt.z = 0

local collisionId = {
    ['ground'] = 2 ^ 5,
    ['flight'] = 2 ^ 6,
    ['water'] = 2 ^ 7,
    ['object'] = 2 ^ 8,
}

local p2p = function(x, y, z)
    return Fix32Vec3(x, z, y)
end

function mt:__tostring()
    return ('%s|%s|%s|%s'):format('point', self.x, self.y, self.z)
end

function mt:get_point()
    return self
end

--distance(point * point)
local sqrt = math.sqrt
function mt:__mul(dest)
    local x1, y1 = self:get_x(), self:get_y()
    local x2, y2 = dest:get_x(), dest:get_y()
    local x0 = x1 - x2
    local y0 = y1 - y2
    return sqrt(x0 * x0 + y0 * y0)
end

--angle(mt / point)
function mt:__div(dest)
    if not dest.get_point then
        print('error', dest, 'wrong parameter type')
    end

    dest = dest:get_point()
    return GameAPI.get_points_angle(self._base, dest._base):float()
end

--get the hight from point to ground
function mt:get_height()
    return GameAPI.get_point_ground_height(self._base):float()
end

function mt:get()
    return self.x, self.y
end

--get global position
function mt:get_x()
    return self.x
end

function mt:get_y()
    return self.y
end

function mt:get_z()
    return self.z
end

function mt:judge_point_in_area(area)
    return GameAPI.judge_point_in_area(self._base, area)
end

function mt:get_collision()
    return up.byte2get(GameAPI.get_point_ground_collision(self._base), 8)
end

function mt:can_move(collision_type)
    local collision = self:get_collision()
    for _, v in ipairs(collision) do
        if v == collisionId[collision_type] then
            return false
        end
    end
    return true
end

function mt:copy()
    return up.point(self.x, self.y, self.z)
end

--move in polar coordinates(point - {angle, distance})
--	@new point
function mt:__sub(data)
    local x, y = self.x, self.y
    local angle, distance = data[1], data[2]
    return up.point(x + distance * math.cos(angle), y - distance * math.sin(angle))
end

function mt:offset(angle, distance)
    local x, y = self.x, self.y
    return up.actor_point(GlobalAPI.get_point_offset_vector(Fix32Vec3(x, 0, y), Fix32(angle), Fix32(distance)))
end

up.actor_point = function(...)
    local point = {}
    local p = nil
    local n = select('#', ...)
    --get point
    if n == 1 then
        -- todo need to supplement the definition of x.y
        p = ...
        if type(p) == 'number' then
            p = GameAPI.get_point_by_res_id(p)
        end
        point.x = GlobalAPI.get_fixed_coord_index(p, 0):float()
        point.y = GlobalAPI.get_fixed_coord_index(p, 2):float()
        point.z = GlobalAPI.get_fixed_coord_index(p, 1):float()
        --get x,y
    elseif n == 2 then
        point.x, point.y = ...
        point.z = 0
        p = p2p(point.x / 100, point.y / 100, 0)
        --get x,y,z
    elseif n == 3 then
        point.x, point.y, point.z = ...
        p = p2p(point.x / 100, point.y / 100, point.z / 100)
    end

    point._base = p
    setmetatable(point, mt)
    return point
end

up.point = function(x, y, z)
    if not z then
        z = 0
    end
    return up.actor_point(x, y, z)
end
