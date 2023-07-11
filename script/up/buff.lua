local table_insert = table.insert
local setmetatable = setmetatable
local table_remove = table.remove
local math_max = math.max
local math_floor = up.math.floor
local pairs = pairs

local mt = {}
mt.__index = mt
mt.type = 'buff'

local Buffs = {}
function up.actor_buff(base)
    local id = base:api_get_modifier_unique_id()
    local key = base:api_get_modifier_key()
    if not Buffs[id] then
        local data = {}
        data._base = base
        for k, v in pairs(up.buff[key]) do
            if data[k] == nil then
                data[k] = v
            end
        end
        local buff = setmetatable(data, mt)
        buff.target = up.actor_unit(base:api_get_owner())
        if base:api_get_releaser() then
            buff.source = up.actor_unit(base:api_get_releaser())
        else
            buff.source = up.actor_unit(base:api_get_owner())
        end
        buff.id = id
        buff.key = key
        buff.skill = up.actor_skill( GlobalAPI.get_related_ability(base))
        buff.name = GameAPI.get_modifier_name_by_type(base:api_get_modifier_key())
        buff.desc = GameAPI.get_modifier_desc_by_type(base:api_get_modifier_key())
        buff.icon = GameAPI.get_icon_id_by_buff_type(base:api_get_modifier_key())

        Buffs[id] = buff
    end
    return Buffs[id]
end

function up.unit_class.__index:new_buff(data)
    if data.source then
        data.source = data.source._base
    end
    local skill = data.skill
    if skill then
        skill = skill._base
    end
    if not data.time then
        data.time = -1
    end
    if not data.updata then
        data.updata = 0
    end
    if not data.stack then
        data.stack = 1
    end
    local bf = self._base:api_add_modifier(
        data.id,
        data.source or nil,
        skill,
        Fix32(data.time),
        Fix32(data.updata),
        data.stack
    )
    local bf2 = up.actor_buff(bf)
    bf2.skill = data.skill
    bf2.update = data.update
    return bf2
end

function up.unit_class.__index.each_buff(self, name)
    local bf_list = self._base:api_get_all_modifiers()
    local group = {}
    for index, value in Python.enumerate(bf_list) do
        local a = up.actor_buff(value)
        table.insert(group,a)
    end
    local n = 0
    return function (t, v)
        n = n + 1
        return t[n]
    end, group
end

--移除buff
function up.unit_class.__index.remove_buff(self, name)
    if type(name) == 'string' then
        name = tonumber(name)
    end
    self._base:api_remove_modifier_type(name)
    self = nil
end

--找buff
function up.unit_class.__index.find_buff_index(self, index,need_show)
    local bf_list = self._base:api_get_all_modifiers()
    local group = {}
    for _, value in Python.enumerate(bf_list) do
        local a = up.actor_buff(value)
        if need_show then
            if a:is_icon_visible() then
                table.insert(group,a)
            end
        else
            table.insert(group,a)
        end
    end
    local bff = group[index]
    if bff then
        return bff
    else
        return nil
    end
end

--是否有BUFF
function up.unit_class.__index.has_buff(self, name)
    if type(name) == 'string' then
        name = tonumber(name)
    end
    return self._base:api_has_modifier(name)
end

function mt:get_name()
    return self.name
end

function mt:get_desc()
    return self.desc
end

function mt:get_icon()
    return self.icon
end

function mt:get_source_unit()
    return self.source
end

function mt:get_source_skill()
    return self.skill
end

function mt:remove()
    self._base:api_remove()
end

function mt:add_stack(stack)
    self._base:api_add_buff_layer(stack)
end

function mt:set_stack(stack)
    self._base:api_set_buff_layer(stack)
end

function mt:add_max_stack(stack)
    self._base:api_add_buff_max_layer(stack)
end

--获取Buff携带者
function mt:get_owner()
    return self.target
end

--获取BuffSource
function mt:get_source()
    return self.source
end

-- function mt:get_pulse()
--     return self._base:
-- end

function mt:add_pulse(time)
    self._base:api_add_cycle_time(time)
end

function mt:set_pulse(time)
    self._base:api_set_cycle_time(time)
end



function mt:add_remaining(time)
    self._base:api_set_buff_residue_time(time)
end

function mt:get_remaining()
    return self._base:api_get_passed_time()
end

function mt:is_icon_visible()
    return self._base:api_get_icon_is_visible()
end


--光环
function mt:get_aura_child()
    --return 
end

function mt:get_aura_range()
end

--缺少护盾相关的api

--mt.source =  self._base:api_get_owner()






local event_name = {
	['on_add']          = {20001,EVENT.OBTAIN_MODIFIER,'Buff-Get'},
	['on_remove']       = {20002,EVENT.LOSS_MODIFIER,'Buff-Lose'},
	['on_can_add']      = {20003,EVENT.MODIFIER_GET_BEFORE_CREATE,'Buff-BeforeGet'},
	['on_stack']        = {20004,EVENT.MODIFIER_LAYER_CHANGE,'Buff-LayerChange'},
	['on_pulse']        = {20005,EVENT.MODIFIER_CYCLE_TRIGGER,'Buff-Tick'},
	['on_cover']        = {20006,EVENT.MODIFIER_BE_COVERED,'Buff-Covered'},
}


local function buff_event_init(buff,name)
    local hook = {}
    for k, v in pairs(event_name) do
        if buff[k] then
        else
            local trg = new_modifier_trigger(tonumber(name), v[1], tostring(v[3]), v[2], true)
            buff[k] = function() end
            function trg.on_event(trigger, event, actor, data)
                if k == 'on_cover' then
                    local new = up.actor_buff(data['__new_modifier'])
                    local old = up.actor_buff(data['__old_modifier'])
                    buff[k](new,old)
                else
                    local bf2 = up.actor_buff(data['__modifier'])
                    buff[k](bf2)
                end
            end
        end
    end
end



up.buff = setmetatable({}, {__index = function(self, name)
    self[name] = {}
    setmetatable(self[name], mt)
    buff_event_init(self[name],name)
    return self[name]
end})


