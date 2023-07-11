local mt = {}
mt.__index = mt
mt.type = 'team'
mt.id = nil

function mt:get_id()
    return self.id
end

function mt:each_player()
    -- local next_player = ac.each_player()
    -- local function next()
    --     local player = next_player()
    --     if not player then
    --         return nil
    --     end
    --     if player:get_slot_id() == self.id then
    --         return player
    --     else
    --         return next()
    --     end
    -- end
    -- return next
end

local all_teams = {}

local inited = false
local function init()
    -- if inited then
    --     return
    -- end
    -- inited = true
    -- for id, data in pairs(ac.table.config.player_setting) do
    --     if not all_teams[id] then
    --         all_teams[id] = setmetatable({ id = id }, mt)
    --     end
    -- end
end

-- function up.team(id)
--     init()
--     return all_teams[id]
-- end

--=========EG==========--

function up.actor_team(u)
    local id = nil
    local base = nil
    if type(u) == "number" then
        id = u
        base = GameAPI.get_camp_by_camp_id(id)
    else
        base = u
        local str = GlobalAPI.camp_to_str(base)
        local _, _, subStr = string.find(str, "([0-9]+)", 1, false)
        id = math.floor(tonumber(subStr))
    end
    if not all_teams[id] then
        local team = {}
        team._base = base
        team.id = id
        all_teams[id] = team
        setmetatable(team, mt)
    end
    return all_teams[id]
end

function up.team(id)
    return up.actor_team(id)
end

function mt:get_all_player()
    --- @class team
    local tb = {}
    for k, v in Python.enumerate(GameAPI.get_role_ids_by_camp(self._base)) do
        tb[k] = up.player(v)
    end
    return tb
end

function mt:show_game_end_ui_by_camp_id(info)
    GameAPI.show_game_end_ui_by_camp_id(self:get_id(), info)
end
