if up.split then return end

local table_insert = table.insert
local math_cos = math.cos
local math_sin = math.sin
local math_rad = math.rad
local math_floor = math.floor

function up.traceback(message)
    print('--------------------------')
    print('LUA ERROR:'..tostring(message)..'|n')
    print(debug.traceback())
    print('--------------------------')
end


function up.split(str, p)
	local rt = {}
	str:gsub('[^'..p..']+', function (w)
		table_insert(rt, w)
	end)
	return rt
end

function up.get_item_kv(key,name)
    return GameAPI.get_item_key_integer_kv(key,name)
end

function up.has_skill_kv(s_id,key,type)
    return GameAPI['has_ability_key_'..KvType[type]..'_kv'](s_id,key)
end

function up.get_skill_kv(s_id,key,vType)
    local value = GameAPI['get_ability_key_'..KvType[vType]..'_kv'](s_id,key)
    if vType == 'real' then
        value = value:float()
    end
    if type(value) ~= 'number' and vType == 'int' then
        value = value:int()
    end
    return value
end


function up.get_item_name(key)
    return GameAPI.get_item_name_by_type(key)
end

function up.get_item_desc(key)
    return GameAPI.get_item_desc_by_type(key)
end

function up.get_item_icon(key)
    return GameAPI.get_item_key_icon(key)
end

function up.get_item_buy_price(key,price_tpye)
    return GameAPI.get_item_buy_price(key, price_tpye):float()
end

function up.get_tech_name(tech)
    return GameAPI.get_tech_name_by_type(tech)
end

function up.get_unit_name(key)
    return GameAPI.get_unit_name_by_type(key)
end

function up.get_unit_icon(key)
    return GameAPI.get_icon_id_by_unit_type(key)
end

function up.get_unit_desc(key)
    return GameAPI.get_unit_desc_by_type(key)
end

function up.get_ability_icon(key)
    return GameAPI.get_icon_id_by_ability_type(key)
end

function up.get_ability_name(key)
    return GameAPI.get_ability_name_by_type(key)
end

function up.get_ability_desc(key)
    return GameAPI.get_ability_desc_by_type(key)
end

function up.get_res_icon(name)
    return GameAPI.get_role_res_icon(name)
end

--get all player attr
    --arg : if curren type only
function up.get_all_resType(must_money)
    local t = {}
    for _, key in Python.enumerate(GameAPI.iter_role_res(must_money)) do
        table.insert(t,key)
    end
    return t
end

function up.create_harm_text(point,type,text,playerGroup)
    GameAPI.create_harm_text(point._base,HarmTextType[type],math.floor(text),ALL_PLAYER)
end

--get game time (about sky box)
function up.get_game_time()
    return GameAPI.get_cur_day_and_night_time():float()
end


function up.get_unit_type_kv(name,type)
    return GameAPI.get_unit_key_unit_name_kv(name,type)
end

EVENT_ID = 700000
function up.get_event_id()
    EVENT_ID = EVENT_ID + 1
    return EVENT_ID
end

function up.table_copy(tbl)
    local a = {}
    for i = 1,#tbl do
        a[i]  = tbl[i]
    end
    return a
end

function table.removeValue(t,value)
    for k,v in ipairs(t) do
        if v == value then
            table.remove(t,k)
            return k
        end
    end
    return nil
end

function up.item_list(list)
	return setmetatable({}, {__newindex = function(_, k, v)
		for _, name in ipairs(list) do
			up.item[name][k] = v
		end
	end})
end

function up.skill_list(list)
	return setmetatable({}, {__newindex = function(_, k, v)
		for _, name in ipairs(list) do
			up.skill[name][k] = v
		end
	end})
end

--number to int
function up.FormatNum (num)
    num = tonumber(num)
	if num <= 0 then
		return 0
	else
		local t1, t2 = math.modf(num)
		if t2 > 0 then
			return num
		else
			return t1
		end
	end
end

function up.byte2bin(n)
    local t = {}
    for i=8,0,-1 do
        t[#t+1] = math.floor(n / 2^i)
        n = n % 2^i
    end
    return table.concat(t)
end


function up.byte2get(n,m)
    local t = {}
    local v
    for i=0,m do
        v = math.floor(n/2^i)
        if v == 1 then
            table.insert(t,2^i)
        end
    end
    return t
end

Print_debug = true
function DebugMsg(text)
    if Print_debug then
        print(text)
    end
end
