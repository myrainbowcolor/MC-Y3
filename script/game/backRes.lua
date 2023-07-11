
local mt = up.skill[BUILD_ID['送回']]

function mt:on_cast_shot()
    local unit = self:get_owner()
    local player = unit:get_owner()
    local target = self:get_target()
    local gold = unit:get'当前携带金币'
    local lumber = unit:get'当前携带木材'
    player:add('金币',gold)
    player:add('木材',lumber)
    if gold > 0 then
        up.create_harm_text(target:get_point(),'获取金币',gold,nil)
    end
    if lumber > 0 then
        up.create_harm_text(target:get_point(),'治疗',lumber,nil)
    end
    unit:set('当前携带金币',0)
    unit:set('当前携带木材',0)
    unit:clear_change_animation('idel1')
    unit:clear_change_animation('attack1')
    unit:clear_change_animation('work')
    unit:clear_change_animation('walk')
end

function mt:on_cast_stop()
    local unit = self:get_owner()
    local skill = unit:find_skill('通用',BUILD_ID['采集'])
    up.wait(0.03,function()
        unit:cast(skill,unit.oldTarget)
    end)
end