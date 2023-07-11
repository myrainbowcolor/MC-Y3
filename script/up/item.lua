--Base attr
local setmetatable = setmetatable
local ipairs = ipairs
local pairs = pairs
local table_insert = table.insert
local math_max = math.max
local math_floor = math.floor

local mt = {}
mt.__index = mt
mt.type = "item"
mt.id = nil
mt.owner = nil  
local event_name = {
    ['on_use']             = {20000,EVENT.UNIT_USE_ITEM,'Item-Use'},
	['on_broken']          = {20001,EVENT.ITEM_BROKEN,'Item-Broken'},
    ['on_hover']             = {20002,EVENT.UNIT_ADD_ITEM,'Item-Use'},
}

function mt:__tostring()
    return ('%s|%s|%s'):format('item', self:get_name(), tostring(self._base))
end

function mt:get_owner()
    return up.actor_unit(self._base:api_get_owner())
end

function mt:is_in_scene()
    return self._base:api_is_in_scene()
end

function mt:get_class()
    return self._base.api_get_key()
end

function mt:get_desc(desc)
    return self._base:api_get_desc()
end

function mt:set_desc(desc)
    self._base:api_set_desc(desc)
end

function mt:set_name(name)
    self._base:set_name(name)
end

function mt:get_name()
    return self._base:get_name()
end

function mt:get_id()
    return self._base.api_get_key()
end

function mt:get_icon()
    return self._base.api_get_item_icon()
    --return GameAPI.get_item_key_icon(self:get_id())
end

function mt:get_point()
    return up.actor_point( self._base.api_get_position())
end

function mt:get_buy_price(price_tpye)
    return GameAPI.get_item_buy_price(self:get_id(),price_tpye):float()
end

function mt:set_level(lv)
    self._base:api_set_level(lv)
end

function mt:get_level()
    return self._base:api_get_level()
end

function mt:get_stack()
    return self._base:api_get_stack_cnt()
end

function mt:set_stack(count)
    self._base:api_set_stack_cnt(count)
end

function mt:add_stack(count)
    self._base:api_add_stack(count)
end

function mt:set_charge(count)
    self._base:api_set_charge_cnt(count)
end

function mt:add_charge(count)
    self._base:api_add_charge(count)
end

function mt:get_max_charge()
    return self._base:api_get_max_charge()
end

function mt:get_charge()
    return self._base:api_get_charge_cnt()
end

function mt:set_max_charge(max_charge)
    self._base:set_max_charge(max_charge)
end

function mt:get_stack_type()
    return self._base:api_get_stack_type()
end

function mt:get_model()
    return self._base:api_get_model()
end

function mt:getTypeKv(key,vType)
    local value = GameAPI['get_item_key_'..KvType[vType]..'_kv'](self:get_id(),key)
    if vType == 'real' then
        value = value:float()
    end
    if type(value) ~= 'number' and vType == 'int' then
        value = value:int()
    end
    return value
end

function mt:remove()
    up.wait(0,function ()
        self._base:api_remove()
    end)
end

up.get_item_type_kv = function(item,key,vType)
    local value = GameAPI['get_item_key_'..KvType[vType]..'_kv'](item,key)
    if vType == 'real' then
        value = value:float()
    end
    if type(value) ~= 'number' and vType == 'int' then
        value = value:int()
    end
    return value
end

up.create_item = function(point,id,player)
    local item = GameAPI.create_item_by_id(point._base,id,player._base)
    return up.actor_item(item)
    --local id = TargetItem:get_key()
    --return  TargetItem
end

local function item_event_init(item,name)
    local hook = {}
    
    for k, v in pairs(event_name) do
        if item[k] then
        else
            local trg = New_item_trigger(name, v[1], tostring(v[3]), v[2], true)
            item[k] = function() end
            function trg.on_event(trigger, event, actor, data)
                -- item._base = GameAPI.get_item(id)
                -- print('create_item_base')
                -- item._iunit = item._base:api_get_item_unit()
                --local ab = setmetatable(data[__ability'], mt)
                --local a = GameAPI.get_item(data['__item_id'])
                local item2 = up.actor_item(data['__item_id'])
                --item._base = a
                --item._base = GameAPI.get_item(data['__item_id'])
                --item._iunit = item._base:api_get_item_unit()
                --item._base =  GameAPI.get_item(data['__item_id'])
                item[k](item2)
            end
        end
    end
end

up.item = setmetatable({}, {__index = function(self, name)
    self[name] = {}
    setmetatable(self[name], mt)
    item_event_init(self[name],name)
    return self[name]
end})


local Items = {}
function up.actor_item(u)
    if not u then return end
    local id 
    if type(u) == 'number' then
        id = u
    else
        id = u:api_get_id()
    end
    if not Items[id] then
        local item = {}
        if GameAPI.get_item(id) then
            item._base = GameAPI.get_item(id)
        else
            item._base = GameAPI.get_item_by_unit_id(id)
        end
        -- if item._base then
        --     item._iunit = item._base:api_get_item_unit()
        -- end
        setmetatable(item, mt)
        Items[id] = item
    end
    return Items[id]
end
