--====EG====--
local mt = {}
mt.__index = mt
mt.type = "area"

local Areas = {}

local function api_get_id(base)
    local str = GlobalAPI.circle_area_to_str(base)
    local _, _, subStr = string.find(str, "([0-9]+)", 1, false)
    return math.floor(tonumber(subStr))
end

function mt:get_id()
    return api_get_id(self._base)
end

function mt:get_circle_radius()
    return GameAPI.get_circle_area_radius(self._base):float() / 2
end

function up.actor_area(obj)
    if not obj then
        return nil
    end
    local base = nil
    if type(obj) == "number" then
        base = GameAPI.get_circle_area_by_res_id(obj)
    else
        base = obj
        obj = api_get_id(obj)
    end
    local id = obj
    if not Areas[id] then
        local area = {}
        area._base = base
        setmetatable(area, mt)
        Areas[id] = area
    end
    return Areas[id]
end

function up.creat_area(point, range)
    local obj = GameAPI.create_new_cir_area(point._base, Fix32(range))
    return up.actor_area(obj)
end
