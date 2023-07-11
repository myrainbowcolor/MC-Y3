local ipairs = ipairs
local pairs = pairs
local setmetatable = setmetatable
local table_remove = table.remove
local table_insert = table.insert

local trigger_map = setmetatable({}, { __mode = 'kv' })

local mt = {}
mt.__index = mt
mt.type = 'trigger'
mt.enable_flag = true
mt.sign_remove = false
-- Event
mt.event = nil

function mt:__tostring()
    return '[table:trigger]'
end

function mt:disable()
    self.enable_flag = false
end

function mt:enable()
    self.enable_flag = true
end

function mt:is_enable()
    return self.enable_flag
end

function mt:__call(...)
    if self.sign_remove then
        return
    end
    if self.enable_flag then
        return self:callback(...)
    end
end

function mt:remove()
    if not self.event then
        return
    end
    trigger_map[self] = nil
    local event = self.event
    self.event = nil
    self.sign_remove = true
    up.wait(0, function()
        for i, trg in ipairs(event) do
            if trg == self then
                table_remove(event, i)
                break
            end
        end
        if #event == 0 then
            if event.remove then
                event:remove()
            end
        end
    end)
end

function up.each_trigger()
    return pairs(trigger_map)
end

-- regist
function up.trigger(event, callback)
    local trg = setmetatable({event = event, callback = callback}, mt)
    table_insert(event, trg)
    trigger_map[trg] = true
    return trg
end
