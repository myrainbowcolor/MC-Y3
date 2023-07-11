
up.game:event('单位-建造',function(_,master,unit)
    if not unit:is_building() then return end
    local player = unit:get_owner()
    local has = unit:hasTypeKv('建造时间','real')
    --if not has then return end
    local time = unit:getTypeKv('建造时间','real')
    local model = unit:getTypeKv('birth','model')

    unit:set('当前生命值',1)
    unit:change_model(model)
    up.wait(0, function()
        unit:add_animation{
            name = 'birth',
            speed = 0,
        }
    end)

    unit.build_max = time
    unit.build_time = 0
    unit.build_addhp = unit:get'生命上限' / (time * 10)
    unit.build_model = model
    unit.build_group = {}

    local skill = master:find_skill('通用',BUILD_ID['修理'])
    if not skill then return end
    up.wait(0.1,function()
        master:cast(skill,unit)
    end)
end)

up.game:event('单位-死亡',function(_,unit)
    if not unit:is_building() then return end
    local model = unit:getTypeKv('death','model')
    unit:change_model(model)
    up.wait(0,function()
        unit:add_animation{
            name = 'death',
        }
    end)
end)

local mt = up.skill[BUILD_ID['修理']]

function mt:on_cast_shot()
    local unit = self:get_owner()
    local player = unit:get_owner()
    local target = self:get_target()
    local time = target.build_max
    local costGold = target:getTypeKv('修理黄金','real') / (time * 10)
    local costLumber = target:getTypeKv('修理木材','real') / (time * 10)
    local buildGold = target:getTypeKv('建造黄金','real')
    local buildLumber = target:getTypeKv('建造木材','real')
    local buildbuff = target:getTypeKv('建造特效','buff')
    local workNum = #target.build_group

    if workNum > 0 then
        if
            player:get'金币' < costGold or
            player:get'木材' < costLumber
        then
            --print('资源不足')
            unit:stop()
            return
        end
    end

    table.insert(target.build_group,unit)

    target:add_animation{
        name = 'birth',
        speed = ( 60 / time) * ( #target.build_group),
    }
    target:add_buff(buildbuff){
        updata = 1,
    }
    if target.build_timer then target.build_timer:remove() end
    target.build_timer = up.loop(0.1,function(t)
        if not target then
            t:remove()
            return
        end
        workNum = #target.build_group
        target.build_time = target.build_time + 0.1 * workNum
        target:add('生命值',target.build_addhp * workNum)
        for k,u in ipairs(target.build_group) do
            if k > 1 then
                if
                    player:get'金币' < costGold or
                    player:get'木材' < costLumber
                then
                    u:stop()
                else
                    player:add('金币',-costGold)
                    player:add('木材',-costLumber)
                end
            end
        end

        if target.build_time >= target.build_max then
            target:cancel_change_model(target.build_model)
            for _,u in ipairs(target.build_group) do
                u:stop()
            end
        end
    end)
end

function mt:on_cast_stop()
    local unit = self:get_owner()
    local target = self:get_target()
    local buildbuff = target:getTypeKv('建造特效','buff')
    table.removeValue(target.build_group,unit)
    target:add_animation{
        name = 'birth',
        speed = ( 60 / target.build_max) * ( #target.build_group),
    }
    if #target.build_group == 0 then
        if target.build_timer then
            target.build_timer:remove()
        end
        if buildbuff then
            target:remove_buff(buildbuff)
        end
    end
end
