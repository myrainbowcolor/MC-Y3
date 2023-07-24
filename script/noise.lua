-- 初始化种子表
local perm = {}
for i = 0, 255 do
    perm[i] = i
end

for i = 0, 255 do
    local j = math.random(0, 255)
    perm[i], perm[j] = perm[j], perm[i]
end

for i = 0, 255 do
    perm[i + 256] = perm[i]
end

-- 柏林噪声函数
---@param x number x坐标
---@param y number y坐标
---@param seed string 种子
---@return number -- 高度坐标
return function(x, y, seed)
    if gameapi then
        gameapi.set_random_seed(seed)
    else
        math.randomseed(tonumber(seed))
    end
    local function fade(t)
        return t * t * t * (t * (t * 6 - 15) + 10)
    end

    local function lerp(from, to, time)
        return from + (to - from) * (time < 0 and 0 or time > 1 and 1 or time)
    end

    local function grad(hash, x, y)
        local h = hash % 16
        local u = h < 8 and x or y
        local v = h < 4 and y or ((h == 12 or h == 14) and x or 0)
        return ((h % 2) == 0 and u or -u) + ((h % 3) == 0 and v or -v)
    end

    local function noise(x, y, perms)
        local X = math.floor(x) % 256
        local Y = math.floor(y) % 256
        local xf = x - math.floor(x)
        local yf = y - math.floor(y)
        local u = fade(xf)
        local v = fade(yf)
        local AA = (perms[X % 256] + Y) % 256
        local AB = (perms[(X + 1) % 256] + Y) % 256
        local BA = (perms[X % 256] + Y + 1) % 256
        local BB = (perms[(X + 1)] % 256 + Y + 1) % 256
        local x1 = lerp(u, grad(perms[AA], xf, yf), grad(perms[AB], xf - 1, yf))
        local x2 = lerp(u, grad(perms[BA], xf, yf - 1), grad(perms[BB], xf - 1, yf - 1))

        return lerp(v, x1, x2)
    end

    return noise(x, y, perm)
end
