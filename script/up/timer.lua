local setmetatable = setmetatable
local ipairs = ipairs
local pairs = pairs
local table_insert = table.insert
local math_max = math.max
local math_floor = math.floor

--[[
    ****todo
    countTimer and restart
    get_timer_elapsed_time
    get_timer_elapsed_time
    get_timer_init_count
    get_timer_remaining_count
    get_current_expired_timer
]]

local mt = {}
mt.__index = mt
mt.type = 'timer'

function mt:get_remaining()
    return GameAPI.get_timer_remaining_time(self.t_id):float()
end

function mt:remove()
    GameAPI.cancel_timer(self.t_id)
    self = nil
end

function mt:pause()
    GameAPI.pause_timer(self.t_id)
end

function mt:resume()
    GameAPI.resume_timer(self.t_id)
end




function up.wait(timeout, on_timer)
    
    local timer
    local a = function ()
        on_timer(timer)
        timer = nil
    end
    local t = GameAPI.add_timer(Fix32(timeout),false,a)
    timer = setmetatable({
        ['timeout'] = timeout,
        ['on_timer'] = on_timer,
        ['timer_count'] = 1,
        ['t_id'] = t
    }, mt)
    return timer
end

function up.loop(timeout, on_timer)
    local timer
    local a = function ()
        on_timer(timer)
    end
    local t = GameAPI.add_timer(Fix32(timeout),true,a)
    timer = setmetatable({
        ['timeout'] = timeout,
        ['on_timer'] = on_timer,
        ['t_id'] = t
    }, mt)
    return timer
end

function up.timer(timeout, count, on_timer)
    if count == 0 then
        return up.loop(timeout, on_timer)
    end
    
    local timer
    local a = function ()
        timer['timer_count'] = timer['timer_count'] - 1
        if timer['timer_count'] <= 0 then
            GameAPI.cancel_timer(timer.t_id)
            timer = nil
        end
        on_timer(timer)
    end
    local t = GameAPI.add_timer(Fix32(timeout),true,a)
    timer = setmetatable({
        ['timeout'] = timeout,
        ['on_timer'] = on_timer,
        ['timer_count'] = count,
        ['t_id'] = t
    }, mt)
    return timer

    -- local t = setmetatable({
    --     ['timeout'] = math_floor(timeout),
    --     ['on_timer'] = on_timer,
    --     ['timer_count'] = count,
    -- }, mt)
    -- m_timeout(t, t.timeout)
    -- return t
end




--[[
local FRAME = 33

local cur_frame = 0
local max_frame = 0
local cur_index = 0
local free_queue = {}
local timer = {}

local function get_remaining(self)
    if self.removed then
        return 0
    end
    if self.pause_remaining then
        return self.pause_remaining
    end
    if self.timeout_frame == cur_frame then
        return self.timeout or 0
    end
    return self.timeout_frame - cur_frame
end

function up.timer_size()
    local n = 0
    for _, ts in pairs(timer) do
        n = n + #ts
    end
    return n
end

function up.timer_all()
    local tbl = {}
    for _, ts in pairs(timer) do
        for i, t in ipairs(ts) do
            if t then
                tbl[#tbl + 1] = t
            end
        end
    end
    return tbl
end


local mt = {}
mt.__index = mt
mt.type = 'timer'

if up.test then
    function mt:__tostring()
        return ('[table:timer:%X]'):format(up.test.topointer(self))
    end
else
    function mt:__tostring()
        return '[table:timer]'
    end
end

function mt:remove()
    self.removed = true
end

function mt:pause()
    if self.removed or self.pause_remaining then
        return
    end
    self.pause_remaining = get_remaining(self)
    self.running = false
    local ti = self.timeout_frame
    local q = timer[ti]
    if q then
        for i = #q, 1, -1 do
            if q[i] == self then
                q[i] = false
                return
            end
        end
    end
end

function mt:resume()
    if self.removed or not self.pause_remaining then
        return
    end
    local timeout = self.pause_remaining
    self.pause_remaining = nil
    m_timeout(self, timeout)
end

function mt:restart()
    if self.removed or self.pause_remaining or not self.running then
        return
    end
    local ti = self.timeout_frame
    local q = timer[ti]
    if q then
        for i = #q, 1, -1 do
            if q[i] == self then
                q[i] = false
                break
            end
        end
    end
    self.running = false
    m_timeout(self, self.timeout)
end

function up.wait(timeout, on_timer)
    GameAPI.start_timer(Fix32(0.2))
    local t = setmetatable({
        ['timeout'] = math_max(math_floor(timeout), 1),
        ['on_timer'] = on_timer,
        ['timer_count'] = 1,
    }, mt)
    m_timeout(t, t.timeout)
    return t
end

function up.loop(timeout, on_timer)
    local t = setmetatable({
        ['timeout'] = math_floor(timeout),
        ['on_timer'] = on_timer,
    }, mt)
    m_timeout(t, t.timeout)
    return t
end

function up.timer(timeout, count, on_timer)
    if count == 0 then
        return up.loop(timeout, on_timer)
    end
    local t = setmetatable({
        ['timeout'] = math_floor(timeout),
        ['on_timer'] = on_timer,
        ['timer_count'] = count,
    }, mt)
    m_timeout(t, t.timeout)
    return t
end

]]