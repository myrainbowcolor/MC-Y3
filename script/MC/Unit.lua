--- @class Unit
--- @field actor Actor
--- @field height number
--- @field width number
--- @field vg number
--- @field v number
--- @field lateCollisionType table<string, boolean>
--- @field collisionType table<string, boolean>
--- @field state string
--- @field time number
--- @field standCube Cube
--- @field jumpInitHeight number
--- @field curVg number
Unit = {} -- 单位类

--- @type table<integer, Unit>
Unit.instanceArr = {} -- 单位实例数组<id, Unit>

--- @param actor Actor
--- @param height number
--- @param width number
--- @return Unit
local function unitInit(actor, height, width)
    local unit = {}
    unit.actor = actor
    unit.height = height
    unit.width = width
    -- 默认数据
    unit.state = "IDLE" -- 待机 < 潜行 = 空中 = 陆地
    unit.collisionType = {
        topCollision = false,
        bottomCollision = false,
        leftCollision = false,
        rightCollision = false,
        frontCollision = false,
        backCollision = false
    }
    unit.vg = 0
    unit.curVg = 0
    unit.v = 500
    unit.time = 0
    local playerInfoTable = GameAPI.get_table("playerInfo")
    if actor:get_team():get_id() == 1 then
        if playerInfoTable["campOneSpawn"] and playerInfoTable["campOneSpawn"] ~= "" then
            local _, _, z = Util:split(playerInfoTable["campOneSpawn"], "|")
            unit.jumpInitHeight = z
        else
            local _, _, z = Util:split(GameAPI.get_table("playerInfo")["point"], "|")
            unit.jumpInitHeight = z
        end
    elseif actor:get_team():get_id() == 2 then
        if playerInfoTable["campTwoSpawn"] and playerInfoTable["campTwoSpawn"] ~= "" then
            local _, _, z = Util:split(playerInfoTable["campTwoSpawn"], "|")
            unit.jumpInitHeight = z
        else
            local _, _, z = Util:split(GameAPI.get_table("playerInfo")["point"], "|")
            unit.jumpInitHeight = z
        end
    end
    unit.standCube = nil
    return unit
end

-- 创建单位
--- @param key number
--- @param centerPoint Vector
--- @param height number
--- @param width number
--- @param playerID integer
--- @return Unit
function Unit:creatUnit(key, height, width, centerPoint, playerID)
    --- @class Actor
    local actor = up.create_unit(key, up.point(centerPoint.x, centerPoint.y, 0), 180, up.player(playerID))
    actor:set_height(centerPoint.z - height / 2)
    return unitInit(actor, height, width)
end

-- 获取单位
--- @param id integer
--- @return Unit
function Unit:getUnit(id)
    return Unit.instanceArr[id]
end

-- 存储单位(直接预设单位实体的时候需要存储)
--- @param actor Actor
local function setUnit(actor)
    local centerPointTemp = actor:get_point()
    local centerPoint = Util:creatVector(
        centerPointTemp:get_x(),
        centerPointTemp:get_y(),
        actor:get_height()
    )
    -- 默认宽高
    local height = GameAPI.get_table("playerInfo")["unitHeight"]:float()
    local width = GameAPI.get_table("playerInfo")["unitWidth"]:float()
    Unit.instanceArr[actor._base:api_get_id()] = unitInit(actor, height, width)
end

-- 获取单位绑定玩家
local function getUnitBindPlayer(unit, key)
    return up.player(GameAPI.get_kv_pair_value_player(unit._base, key):get_role_id_num())
end

-- 获取单位绑定字符串值
local function getUnitBindString(unit, key)
    return GameAPI.get_kv_pair_value_string(unit._base, key)
end

-- 添加单位实例
up.game:event("Unit-Create", function(trigger, unit)
    local unitType = getUnitBindString(unit, "TYPE")
    if unitType == "PLAYER" then
        setUnit(unit)
        local str = nil
        local playerInfoTable = GameAPI.get_table("playerInfo")
        if unit:get_team():get_id() == 1 then
            if playerInfoTable["campOneSpawn"] and playerInfoTable["campOneSpawn"] ~= "" then
                str = playerInfoTable["campOneSpawn"]
            else
                str = playerInfoTable["point"]
            end
        elseif unit:get_team():get_id() == 2 then
            if playerInfoTable["campTwoSpawn"] and playerInfoTable["campTwoSpawn"] ~= "" then
                str = playerInfoTable["campTwoSpawn"]
            else
                str = playerInfoTable["point"]
            end
        end
        local x, y, z = Util:split(str, "|")
        unit:set_point(up.point(tonumber(x) or 0, tonumber(y) or 0, 0))
        unit:set_height(tonumber(z) or 0)
        -- print(x, y, z)
    end
end)

-- 移除单位实例
up.game:event("Unit-Delete", function(trigger, ...)
    local actor = ...
    Unit.instanceArr[actor._base:api_get_id()] = nil
end)

-- 获取单位中心点
--- @param unit Unit
function Unit:getUnitCenterPoint(unit)
    if not unit.actor:is_destroyed() then
        local unitPointTemp = unit.actor:get_point()
        local x = unitPointTemp:get_x()
        local y = unitPointTemp:get_y()
        local z = unit.actor:get_height() + unit.height / 2
        return Util:creatVector(x, y, z)
    end
end

-- 获取单位头部点
--- @param unit Unit
function Unit:getUnitTopPoint(unit)
    if not unit.actor:is_destroyed() then
        local centerPoint = Unit:getUnitCenterPoint(unit)
        return Util:creatVector(
            centerPoint.x,
            centerPoint.y,
            centerPoint.z + unit.height / 2
        )
    end
end

-- 获取单位底部点
--- @param unit Unit
function Unit:getUnitBottomPoint(unit)
    if not unit.actor:is_destroyed() then
        local centerPoint = Unit:getUnitCenterPoint(unit)
        return Util:creatVector(
            centerPoint.x,
            centerPoint.y,
            centerPoint.z - unit.height / 2
        )
    end
end

return Unit
