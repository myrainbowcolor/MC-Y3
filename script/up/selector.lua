
local math = math
local table = table
local table_insert = table.insert
local table_sort = table.sort
local setmetatable = setmetatable
local ipairs = ipairs

local mt = {}

mt.__index = mt

mt.type = 'selector'


mt.filters = nil

--custom conditions
function mt:add_filter(f)
	table_insert(self.filters, f)
	return self
end

--selection rules
	--circular range
	-- center of circle
	-- radius
	function mt:in_range(p, r)
		self.filter_in = 'range'
		self.center = p
		self.r = r
		return self
	end

-- sector range
	-- center of circle
	-- radius
	--	angle
	-- interval
	function mt:in_sector(p, r, angle, section)
		self.filter_in = 'sector'
		self.center = p
		self.r = r
		self.angle = angle
		self.section = section
		return self
	end

--rectangular extent
	-- starting point
	--	angle
	--	length
	-- width
	function mt:in_line(p, angle, len, width)
		self.filter_in = 'line'
		self.center = p
		self.angle = angle
		self.length = len
		self.width = width
		return self
	end

--ring range
	-- center of circle
	-- inner ring
	-- Outer ring
	function mt:in_annular(p, r1, r2)
		self.filter_in = 'annular'
		self.center = p
		self.small_r = r1
		self.big_r = r2
		return self
	end

	-- in the area
	function mt:in_area(area)
		self.area = area
	end

--filter rules
	-- not the specified unit
	--   unit
	function mt:is_not(u)
		return self:add_filter(function(dest)
			return dest ~= u
		end)
	end

	-- is the enemy
	--   reference unit/player
	function mt:is_enemy(u)
		return self:add_filter(function(dest)
			return dest:is_enemy(u)
		end)
	end

	-- is friendly
	--   reference unit/player
	function mt:is_ally(u)
		return self:add_filter(function(dest)
			return dest:is_ally(u)
		end)
	end

	function mt:is_player(player)
		return self:add_filter(function(dest)
			return dest:get_owner() == player
		end)
	end

	function mt:is_not_buff(name)
		return self:add_filter(function(dest)
			return not dest:find_buff(name)
		end)
	end

	function mt:has_tag(tag)
		return self:add_filter(function(dest)
			return dest:has_tag(tag)
		end)
	end

	function mt:is_hero()
		return self:add_filter(function(dest)
			return dest:is_type('hero')
		end)
	end

	function mt:is_type(type)
		return self:add_filter(function(dest)
			return dest:is_type(type)
		end)
	end

	--unitname(key)
	function mt:is_unitType(id)
		return self:add_filter(function(dest)
			if dest.type ~= 'unit' then
				return false
			else
				return dest:get_key() == id
			end
		end)
	end

	function mt:is_not_hero()
		return self:add_filter(function(dest)
			return not dest:is_type('hero')
		end)
	end

	function mt:is_building()
		return self:add_filter(function(dest)
			return dest:is_type('building')
		end)
	end

	function mt:is_not_building()
		return self:add_filter(function(dest)
			return not dest:is_type('building')
		end)
	end

	function mt:is_not_in_table(t)
		return self:add_filter(function(dest)
			for _,v in ipairs(t) do
				if v == dest then
					return false
				end
			end
			return true
		end)
	end

	function mt:is_visible(u)
		return self:add_filter(function(dest)
			return dest:is_visible(u)
		end)
	end

	function mt:is_illusion()
		return self:add_filter(function(dest)
			return dest:is_illusion()
		end)
	end

	function mt:is_not_illusion()
		return self:add_filter(function(dest)
			return not dest:is_illusion()
		end)
	end

	function mt:allow_god()
		self.is_allow_god = true
		return self
	end

	function mt:allow_dead()
		self.is_allow_dead = true
		return self
	end

--Filter the selected units
function mt:do_filter(u)

	if not self.is_allow_dead and not u:is_alive() then
		return false
	end

	for i = 1, #self.filters do
		local filter = self.filters[i]
		if not filter(u) then
			return false
		end
	end
	return true
end

--sort
	function mt:set_sorter(f)
		self.sorter = f
		return self
	end

	--sort index distance with poi
	function mt:sort_nearest_unit(poi)
		local poi = poi:get_point()
		return self:set_sorter(function (u1, u2)
			return u1:get_point() * poi < u2:get_point() * poi
		end)
	end

	--sort index ：1、Hero 2、distance with poi
	function mt:sort_nearest_hero(poi)
		local poi = poi:get_point()
		return self:set_sorter(function (u1, u2)
			if u1:is_hero() and not u2:is_hero() then
				return true
			end
			if not u1:is_hero() and u2:is_hero() then
				return false
			end
			return u1:get_point() * poi < u2:get_point() * poi
		end)
	end

	function mt:sort_nearest_type_hero(poi)
		local poi = poi:get_point()
		return self:set_sorter(function (u1, u2)
			if u1:is_type('hero') and not u2:is_type('hero') then
				return true
			end
			if not u1:is_type('hero') and u2:is_type('hero') then
				return false
			end
			return u1:get_point() * poi < u2:get_point() * poi
		end)
	end

--use selector
function mt:select(select_unit)
    local g
	if self.filter_in == 'range' then
		g = GameAPI.filter_unit_id_list_in_area(
            self.center:get_point()._base,
            GlobalAPI.create_circular_shape(
                Fix32(self.r)
            )
        )
	elseif self.filter_in == 'sector' then
		g = GameAPI.filter_unit_id_list_in_area(
            self.center:get_point()._base,    --center point
            GlobalAPI.create_sector_shape(
                Fix32(self.r),          --radius
                Fix32(self.section),    --included angle
                self.angle              --towards
            )
        )
	elseif self.filter_in == 'line' then
		g = GameAPI.filter_unit_id_list_in_area(
            self.center:get_point()._base,    --center point
            GlobalAPI.create_rectangle_shape(
                Fix32(self.width),      --length
                Fix32(self.length),     --width
                Fix32(self.angle)       --angle
            )
		)
	elseif self.filter_in == 'annular' then
		g = GameAPI.filter_unit_id_list_in_area(
            self.center:get_point()._base,    --center point
            GlobalAPI.create_annular_shape(
                Fix32(self.small_r),    --inner ring
                Fix32(self.big_r)    	--outer ring
            ))
	elseif self.filter_in == 'area' then
		g = GameAPI.get_unit_group_in_area(self.area)
    end

    for i in Python.enumerate(g) do
		local unit = up.actor_unit(g[i])
		if self:do_filter(unit) then
        	select_unit(unit)
		end
    end
end

function mt:get()
	local units = {}
	self:select(function (u)
        table_insert(units, u)
    end)
	if self.sorter then
		table_sort(units, self.sorter)
	end
	return units
end

function mt:ipairs()
    return ipairs(self:get())
end

function mt:random()
    local g = self:get()
    if #g > 0 then
        return g[GameAPI.randint(1,#g)]
    end
end

function up.selector()
	return setmetatable({filters = {}}, mt)
end

function up.selectorFilter(callback)
    DefaultFilter = callback
end
