
local unit = up.unit_class

function unit.__index.get_tech_list(self)
    local a = self._base:api_get_tech_list()
    local r = {}
    for _, value in Python.enumerate(a) do
        table.insert(r,value)
    end
    return r
end

function unit.__index.get_tech_index(self,index)
    return self:get_tech_list()[index]
end

function unit.__index.check_tech(self,tech_key)
    return self._base:api_check_tech_precondition(tech_key)
end

function up.get_tech_icon(tech_key,level)
    return GameAPI.get_tech_icon(tech_key,level)
end

function up.get_tech_cost(tech_key,level)
    local a = GameAPI.get_tech_cost(tech_key,level)
    local r = {}
    for _, value in Python.enumerate(a) do
        local vt = {}
        for _, v in Python.enumerate(value) do
            table.insert(vt,v)
        end
        r[vt[1]] = vt[2]:float()
    end
    return r
end

function up.get_tech_cost_res(tech_key,level,res)
    return up.get_tech_cost(tech_key,level)[res]
end

function up.get_tech_name(tech_key)
    return GameAPI.get_tech_name_by_type(tech_key)
end

function up.get_tech_desc(tech_key)
    return GameAPI.get_tech_desc_by_type(tech_key)
end

function up.get_tech_max_level(tech_key)
    return GameAPI.get_tech_max_level(tech_key)
end
