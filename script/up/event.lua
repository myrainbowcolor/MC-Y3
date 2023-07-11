local setmetatable = setmetatable
local ipairs = ipairs
local pairs = pairs
local table = table
local unpack = unpack
local up_game = up.game

local cmd_parmlist = {
    [1] = {'Command-Move',{'__point','point'}},
    [2] = {'Command-AttackMove',{'__point','point'}},
    [3] = {'Command-Attack',{'__target_unit','unit'},{'__destructible_id','des'}},
    [4] = {'Command-Patrol',{'__point','point'}},
    [5] = {'Command-Stop'},
    [6] = {'Command-Garrison',{'__point','point'}},
    [8] = {'Command-PickUpItem',{'__item_id','item'}},
    [9] = {'Command-DiscardItem',{'__item_id','item'}},
    [10] = {'Command-GiveItem',{'__item_id','item'},{'__target_unit','unit'}},
    [11] = {'Command-Follow',{'__target_unit','unit'}},
    [12] = {'Command-MoveAlongPath'},
}

local enum_f = {
    player = function (r_id) return up.player(r_id) end,
    unit = function(u) return up.actor_unit(u) end,
    item = function(u) return up.actor_item(u) end,
    skill = function (u) return up.actor_skill(u) end,
    point = function (u) return up.actor_point(u) end,
    buff = function(u) return up.actor_buff(u) end,
    group = function (u)
        local group = {}
        for index, value in Python.enumerate(u) do
            local a = up.actor_unit(value)
            table.insert(group,a)
        end
        return group
    end,
    des = function (u)
        return up.actor_destructable(u)
    end
}

--Fire Event to first arg
local event_list = {
    {EVENT.GAME_INIT,                   'Game-Init'},
    {EVENT.LOADING_END,                 'Game-LoadingEnd'},
    {EVENT.UNIT_ATTR_CHANGE,            'Unit-AttrChange'},
    {EVENT.UNIT_BORN,                   'Unit-Create',{{'__unit_id','unit'}}},
    {EVENT.UNIT_DIE,                    'Unit-Die',{{'__target_unit','unit'},{'__source_unit','unit'}},true},
    {EVENT.UNIT_REMOVE,                 'Unit-Delete',{{'__unit_id','unit'}}},
    {EVENT.KILL_UNIT,                   'Unit-Kill',{{'__source_unit','unit'}},true},
    {EVENT.UNIT_ADD_ITEM,               'Unit-GetItem',{{'__unit_id','unit'},{'__item_id','item'},'__item_no'}},
    {EVENT.UNIT_REMOVE_ITEM,            'Unit-LoseItem',{{'__unit_id','unit'},{'__item_id','item'},'__item_no'}},
    {EVENT.UNIT_USE_ITEM,               'Unit-UseItem',{{'__unit_id','unit'},{'__item_id','item'},'__item_no'},true},
    {EVENT.SELECT_UNIT,                 'Unit-SingleSelect',{{'__role_id','player'},{'__unit_id','unit'}}},
    {EVENT.SELECT_UNIT_GROUP,           'Unit-MutiSelect',{{'__role_id','player'},{'__unit_group_id_list','group'},'__team_id'}},
    {EVENT.UNIT_BE_HURT,                'Unit-BeHurt',{{'__target_unit','unit'},{'__source_unit','unit'},{'__ability','skill'},'__damage','__damage_type'},true},
    {EVENT.UNIT_HURT_OTHER,             'Unit-HurtOther',{{'__source_unit','unit'},{'__target_unit','unit'},{'__ability','skill'},'__damage','__damage_type'}},
    {EVENT.UNIT_ON_COMMAND,             'Unit-OnCommand',{{'__unit_id','unit'},'__cmd_type'}},
    {EVENT.UPGRADE_UNIT,                'Unit-Upgrade',{{'__unit_id','unit'}}},
    {EVENT.UNIT_END_NAV_EVENT,          'Unit-EndNav',{{'__unit_id','unit'}}},
    {EVENT.UNIT_START_NAV_EVENT,        'Unit-StartNav',{{'__unit_id','unit'}}},
    {EVENT.AREA_ENTER,                  'Unit-EnterArea'},
    {EVENT.ABILITY_BUILD_FINISH,        'Unit-Build',{{'__unit_id','unit'},{'__build_unit_id','unit'}}},
    {EVENT.ROLE_RESOURCE_CHANGED,       'Player-ResourceChange',{{'__role_id','player'},'__res_key'}},
    {EVENT.ROLE_TECH_CHANGED,           'Player-TechChange',{'__tech_no',{'__role_id','player'}}},
    {EVENT.START_SKILL_POINTER,         'Player-StartSkillPointer',{{'__role_id','player'},{'__unit_id','unit'},'__ability_type','__ability_index'}},
    {EVENT.STOP_SKILL_POINTER,          'Player-StopSkillPointer',{{'__role_id','player'},{'__unit_id','unit'},'__ability_type','__ability_index'}},
    {EVENT.SELECT_ITEM,                 'Item-Select',{{'__role_id','player'},{'__item_id','item'}}},
    {EVENT.ABILITY_OBTAIN,              'Skill-Get',{{'__ability','skill'}}},
    {EVENT.ABILITY_LOSE,                'Skill-Lose',{{'__ability','skill'}}},
    {EVENT.ABILITY_ATTR_CHANGED,        'Skill-AttrChange',{{'__ability','skill'}}},
    {EVENT.ABILITY_PS_START,            'Skill-PSStart',{{'__ability','skill'}}},
    {EVENT.ABILITY_CS_START,            'Skill-CSStart',{{'__ability','skill'}}},
    {EVENT.ABILITY_PS_END,              'Skill-PSStart',{{'__ability','skill'}}},
    {EVENT.ABILITY_END,                 'Skill-End',{{'__ability','skill'}}},
    {EVENT.MODIFIER_CYCLE_TRIGGER,      'BUFF-Tick',{{'__modifier','buff'},{'__owner_unit','unit'},{'__from_unit_id','unit'}}},
    {EVENT.SELECT_DEST,                 'Destructible-Select',{{'__role_id','player'},{'__destructible_id','des'}}},
    {{EVENT.MOUSE_KEY_DOWN_EVENT,240},  'Mouse-LeftDown',{{'__role_id','player'},{'__pointing_world_pos','point'}}},
    {{EVENT.MOUSE_KEY_DOWN_EVENT,241},  'Mouse-RightDown',{{'__role_id','player'},{'__pointing_world_pos','point'}}},
    {{EVENT.MOUSE_KEY_UP_EVENT,240},    'Mouse-LeftRelease',{{'__role_id','player'},{'__pointing_world_pos','point'}}},
    {{EVENT.MOUSE_KEY_UP_EVENT,241},    'Mouse-RightRelease',{{'__role_id','player'},{'__pointing_world_pos','point'}}},
    {{EVENT.MOUSE_WHEEL_EVENT,0xF3},      'Mouse-WheelUp',{{'__role_id','player'},'__mouse_wheel'}},
    {{EVENT.MOUSE_WHEEL_EVENT,0xF4},      'Mouse-WheelDown',{{'__role_id','player'},'__mouse_wheel'}},
    {EVENT.KEYBOARD_KEY_UP_EVENT,       'Keyboard-Up',{'__current_key',{'__role_id','player'}}},
    {EVENT.KEYBOARD_KEY_DOWN_EVENT,     'Keyboard-Down',{'__current_key',{'__role_id','player'}}},
    {EVENT.ITEM_PRECONDITION_SUCCEED,     'Item-RreconditionSucceed',{'__item_no',{'__role_id','player'}}},
    {EVENT.ITEM_PRECONDITION_FAILED,     'Item-RreconditionFailed',{'__item_no',{'__role_id','player'}}},
    {EVENT.TECH_PRECONDITION_SUCCEED,     'Tech-RreconditionSucceed',{'__tech_no',{'__role_id','player'}}},
    {EVENT.TECH_PRECONDITION_FAILED,     'Tech-RreconditionFailed',{'__tech_no',{'__role_id','player'}}},
    
}

--register UIEvent
for _,v in pairs(UI_EVENT_LIST) do
    --print('init event',v)
    local a = {{EVENT.TRIGGER_COMPONENT_EVENT,v},'UI-Event',{{'__role_id','player'},'__ui_event_name','__comp_name'}}
    table.insert(event_list,a)
end

for i = 1,255 do
    local a = {{EVENT.KEYBOARD_KEY_DOWN_EVENT,i},'Keyboard-Down',{{'__role_id','player'},'__current_key'}}
    table.insert(event_list,a)
    local a = {{EVENT.KEYBOARD_KEY_UP_EVENT,i},'Keyboard-Up',{{'__role_id','player'},'__current_key'}}
    table.insert(event_list,a)
end

local function cmd_event(tbl,cmd,data)
    --add Event arg by cmd
    local name = cmd[1]
    table.insert(tbl,name)
    if #cmd > 1 then
        for i=2,#cmd do
            if data[cmd[i][1]] then
                table.insert(tbl,enum_f[cmd[i][2]](data[cmd[i][1]]))
            end
        end
    end
end

local n = 0
for _, event in ipairs(event_list) do
    --up.print('bbb')
    local trg = new_global_trigger(100000+n, event[2], event[1], true)
    n = n+1
    -- if event[5] == 'AREA' then
    --     trg.event.target_type = "Area"
    --     trg.event.get_target = function(trigger, actor)
    --         return gameapi.get_rec_area_by_res_id(event[6])
    --     end
    -- end
    trg.on_event = function(trigger,event_name,actor,data)
        local tbl = {}
        if event[3] then
            for _,name in pairs (event[3]) do
                if type(name) == 'table' then
                    if data[name[1]] then
                        table.insert(tbl,enum_f[name[2]](data[name[1]]))
                    end
                else
                    if data[name] then
                        if name == '__cmd_type' then
                            if cmd_parmlist[data[name]] then
                                cmd_event(tbl,cmd_parmlist[data[name]],data)
                            end
                        else
                            table.insert(tbl,data[name])
                        end
                    end
                end
            end
        end
        if tbl[1] then
            if event[4] then
                tbl[1]:event_notify(event[2], unpack(tbl))
                return
            end
        end
        -- if event[2] == 'Unit-Die' then
        --     up.print('game over',tbl[1]:get_name())
        -- end
        
        up.game:event_notify(event[2], unpack(tbl))
    end
end



function up.event_dispatch(obj, name, ...)
    local events = obj._events
    if not events then
        return
    end
    local event = events[name]
    if not event then
        return
    end
    for i = #event, 1, -1 do
        local res, arg = event[i](...)
        if res ~= nil then
            return res, arg
        end
    end
end

function up.event_notify(obj, name, ...)
    local events = obj._events
    if not events then
        return
    end
    local event = events[name]
    if not event then
        return
    end
    for i = #event, 1, -1 do
        event[i](...)
    end
end

function up.event_register(obj, name, f)
    local events = obj._events
    if not events then
        events = {}
        obj._events = events
    end
    local event = events[name]
    if not event then
        event = {}
        events[name] = event
        local up_event = name
        if obj.event_subscribe then
            obj:event_subscribe(up_event)
        end
        function event:remove()
            events[name] = nil
            if obj.event_unsubscribe then
                obj:event_unsubscribe(up_event)
            end
        end
    end
    return up.trigger(event, f)
end

function up.game:event_dispatch(name, ...)
    return up.event_dispatch(self, name, ...)
end

function up.game:event_notify(name, ...)
    return up.event_notify(self, name, ...)
end

function up.game:event(name, f)
    return up.event_register(self, name, f)
end
