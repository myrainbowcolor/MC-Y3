--{'Command-Move',{'__point','point'}},
--{'Command-AttackMove',{'__point','point'}},
--{'Command-Attack',{'__target_unit','unit'},{'__destructible_id','des'}},
--{'Command-Patrol',{'__point','point'}},
--{'Command-Stop'},
--{'Command-Garrison',{'__point','point'}},
--{'Command-PickUpItem',{'__item_id','item'}},
--{'Command-DiscardItem',{'__item_id','item'}},
--{'Command-GiveItem',{'__item_id','item'},{'__target_unit','unit'}},
--{'Command-Follow',{'__target_unit','unit'}},
--{'Command-MoveAlongPath'},

up.game:event('Unit-OnCommand',function(_,unit,order, ...)

    --destructable handler
    if order == 'Command-Attack' then
        local target = ...
        if target.type == 'destructable' then
            unit:event_dispatch( order..'destructable', unit,target)
            return
        end
    end
    unit:event_dispatch(order,unit,...)
end)

local a_type = {
    [0]= 'Hide',
    [1] = 'Normal',
    [2] = 'Common',
    [3] = 'Hero',
}


up.game:event('Player-StartSkillPointer',function(_,player,unit,type,index)
    local skill = unit:find_skill(a_type[type],nil,index)
    up.game:event_dispatch('SkillPointer-Show',player,skill)
end)

up.game:event('Player-StopSkillPointer',function(_,player,unit,type,index)
    local skill = unit:find_skill(a_type[type],nil,index)
    up.game:event_dispatch('SkillPointer-Hide',player,skill)
end)