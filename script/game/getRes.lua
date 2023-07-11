
local mt = up.skill[BUILD_ID['采集']]

local goBack = function(unit,resType)
    unit:stop()
    local g = up.selector()
        :in_range(unit:get_point(),99999)
        :is_unitType(BUILD_ID['基地'])
        :is_player(unit:get_player())
        :get()
    if not g[1] then
        return
    end
    local skill = unit:find_skill('通用',BUILD_ID['送回'])
    if skill then
        up.wait(0.03,function()
            unit:cast(skill,g[1])
        end)
    end
end

--  todo:集群施法
function mt:on_start()
    local unit = self:get_owner()
    local target = self:get_target()
    local player = unit:get_owner()

    if not player.select_unit then return end
    if player.select_group then
        for _,u in ipairs(player.select_group) do
            if u ~= unit then
                local skill = unit:find_skill('通用',BUILD_ID['采集'])
                u:cast(skill,target)
            end
        end
    end
end

function mt:on_cast_start()
    local unit = self:get_owner()
    local player = unit:get_owner()
    local target = self:get_target()
    unit.goBack = true
    unit.oldTarget = target

    if target:get_name() == '金矿' then
        unit:change_animation('idel1','attack_idelGold')
        unit:change_animation('attack1','attackGold')
        unit:change_animation('work','workGold')
        unit:change_animation('walk','walkGold')
        if unit:get'当前携带金币' >= unit:get'单次采集金币' then
            unit.resType = '金币'
            unit:stop()
        end
    elseif target:get_name() == '树木' then
        unit:change_animation('idel1','attack_idelLumber')
        unit:change_animation('attack1','attackLumber')
        unit:change_animation('work','workLumber')
        unit:change_animation('walk','walkLumber')
        if unit:get'当前携带木材' >= unit:get'携带木材上限' then
            unit.resType = '木材'
            unit:stop()
        end
    end
end

function mt:on_cast_shot()
    local unit = self:get_owner()
    local player = unit:get_owner()
    local target = self:get_target()
    local getNum
    unit.goBack = false

    if target:get_name() == '金矿' then
        if unit:get'当前携带金币' ~= 0 then
            getNum = unit:get'单次采集金币' - unit:get'当前携带金币'
            unit.goBack = true
        else
            getNum = unit:get'单次采集金币'
        end
        unit:set('当前携带金币',unit:get'当前携带金币' + getNum)
    elseif target:get_name() == '树木' then
        if unit:get'当前携带木材' + unit:get'单次采集木材' > unit:get'携带木材上限' then
            getNum = unit:get'携带木材上限' - unit:get'当前携带木材'
            unit.goBack = true
        else
            getNum = unit:get'单次采集木材'
        end
        unit:set('当前携带木材',unit:get'当前携带木材' + getNum)
        if not target.resource then
            target:set_resource(9999999)
        end
        target:add_resource(-1)
    end
end

function mt:on_cast_stop()
    local unit = self:get_owner()
    if unit.goBack then
        goBack(unit,unit.resType)
    else
        unit:cast(self,self:get_target())
    end
end