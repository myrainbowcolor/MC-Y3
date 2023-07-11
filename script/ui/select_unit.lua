
local ui_comp = require 'ui.ui_comp'
local tech_list_ui = ui_comp.tech_list_ui
local hero_total_attr_ui = ui_comp.hero_total_attr_ui

local function math_round(nNum,n)
    if type(nNum) ~='number' then
        return nNum
    end
    n = n or 0
    n = math.floor(n + 0.5)
    if n < 0 then
        n = 0
    end
    local nDecimal = 10 ^ n
    local nTemp = math.floor((nNum * nDecimal) + 0.5)
    local nRet = nTemp / nDecimal
    return nRet
end

local function update_attr(player,unit)
    local total_attr_table = hero_total_attr_ui
    if not unit or not unit:is_alive() then
        up.ui:hide('Role','',player)
        if player._updateAttrTimer then player._updateAttrTimer:remove() end
    end
    for attr,ui in pairs(total_attr_table) do
        local value = unit:get(attr,'Base') + unit:get(attr,'Extra')
        if value > 0 then
            value = string.format('%d',tostring(math_round(value)))
            if attr == 'attack_speed' then
                value = tostring(math_round(unit:get_attack_speed(),2))
            end
            if attr == 'strength' or attr == 'agility' or attr == 'intelligence' then
                value = string.format('%d',tostring(math_round(value,2)))
            end
        end
        up.ui:set_text(ui,value,player)
    end
end



local function group_refresh(player)
    local unit = player.select_unit
    local group = player.select_group
    if not unit then return end
    if not group then
        if player._attr_timer then player._attr_timer:remove() end
        return
    end
    if #group == 0 then
        player.select_group = nil
        return
    end
    for i = 1,16 do
        if i <= #group then
            up.ui:show('choose_unit_'..i,'',player)
            up.ui:hide('MutiTargerHeighlight_'..i,'',player)
        else
            up.ui:hide('choose_unit_'..i,'',player)
        end
    end
    for k,v in ipairs(group) do
        if v:is_alive() == false then
            table.remove(group,k)
            if v == unit then
                if #group == 0 then
                    up.ui:hide('Role','',player)
                    return
                else
                    player.select_unit = group[1]
                end
            end
            group_refresh(player, group)
            return
        end

        if v == unit then
            up.ui:show('MutiTargerHeighlight_'..(k),'',player)
        end

        up.ui:set_image('unit_head'..(k),v:get_icon(),player)
        up.ui:set_progress('m_unit_hp_'..(k), v:get'hp_max', v:get'hp_cur',player)
        up.ui:set_progress('m_unit_mp_'..(k), v:get'mp_max', v:get'mp_cur',player)
    end
    -- controlPanel
    if unit:is_hero() then
        for _,ui in ipairs(ui_comp.hero_lmz_ui) do
            if gameapi.api_if_pri_attr_state_open() then
                up.ui:show(ui,'',player)
            end
        end
    else
        for _,ui in ipairs(ui_comp.hero_lmz_ui) do
            up.ui:hide(ui,'',player)
        end
    end

    update_attr(player,unit)
    up.ui:set_text('choose_unit_name',unit:get_name(),player)
    up.ui:set_text('choose_unit_lv',unit:get_level(),player)
    up.ui:set_text('hp_txt',string.format('%d', unit:get'hp_cur')..'/'..string.format('%d', unit:get'hp_max'),player)
    up.ui:set_text('mp_txt',string.format('%d', unit:get'mp_cur')..'/'..string.format('%d', unit:get'mp_max'),player)
    up.ui:set_progress('main_hp_bar_v',unit:get'hp_max',unit:get'hp_cur',player)
    up.ui:set_progress('main_mp_bar_v',unit:get'mp_max',unit:get'mp_cur',player)

    --  MutiTarget
    for k,v in pairs(group) do
        up.ui:set_progress('m_unit_hp_'..(k), v:get'hp_max', v:get'hp_cur',player)
        up.ui:set_progress('m_unit_mp_'..(k), v:get'mp_max', v:get'mp_cur',player)
    end

end

local function control_refresh(player,unit)
    if unit:is_hero() and gameapi.api_if_pri_attr_state_open() then
        for _,ui in ipairs(ui_comp.hero_lmz_ui) do
            up.ui:show(ui,'',player)
        end
    else
        for _,ui in ipairs(ui_comp.hero_lmz_ui) do
            up.ui:hide(ui,'',player)
        end
    end 

    up.ui:set_text('choose_unit_name',unit:get_name(),player)
    up.ui:set_model('choose_unit_showroom',unit:get_model(),player)
    if player._updateAttrTimer then player._updateAttrTimer:remove() end
    player._updateAttrTimer = up.loop(0.033,function()
        update_attr(player,unit)

        if unit:is_hero() then
            up.ui:set_progress('exp_bar',unit:get_up_need_exp(),unit:get_exp(),player)
        end

        up.ui:set_text('choose_unit_lv',unit:get_level(),player)
        up.ui:set_text('hp_txt',string.format('%d', unit:get'hp_cur')..'/'..string.format('%d', unit:get'hp_max'),player)
        up.ui:set_text('mp_txt',string.format('%d', unit:get'mp_cur')..'/'..string.format('%d', unit:get'mp_max'),player)
        up.ui:set_progress('main_hp_bar_v',unit:get'hp_max',unit:get'hp_cur',player)
        up.ui:set_progress('main_mp_bar_v',unit:get'mp_max',unit:get'mp_cur',player)
    end)
end


local function link_tech(player,unit)
    local tech_list = unit:get_tech_list()
    if player._updateTechTimer then player._updateTechTimer:remove() end
    if #tech_list > 0 then
        up.ui:show('tech','',player)
        for i=1,#tech_list do
            local tech = tech_list[i]
            local level = player:get_tech_level(tech)
            local dis = player:check_tech_precondition(tech)
            up.ui:show(tech_list_ui[i],'',player)
            up.ui:set_image('tech_icon_('..i..')',up.get_tech_icon(tech,level+1),player)
            up.ui:set_text('tech_level_'..i,level,player)
            if dis then
                up.ui:hide('tech_jinyong_('..i..')','',player)
            else
                up.ui:show('tech_jinyong_('..i..')','',player)
            end
        end
        if #tech_list < TECH_MAX then
            for i = #tech_list + 1,TECH_MAX do
                up.ui:hide(tech_list_ui[i],'',player)
            end
        end
        player._updateTechTimer = up.loop(0.033,function()
            if not unit or not unit:is_alive() then
                up.ui:hide('Role','',player)
                up.ui:hide('tech','',player)
                if player._updateTechTimer then player._updateTechTimer:remove() end
                return
            end
            for i=1,#tech_list do
                local tech = tech_list[i]
                local dis = player:check_tech_precondition(tech)
                local level = player:get_tech_level(tech)
                local level_max = up.get_tech_max_level(tech)
                if level_max == level then
                    up.ui:hide(tech_list_ui[i],'',player)
                end
                up.ui:set_text('tech_level_'..i,level,player)
                if dis then
                    up.ui:hide('tech_jinyong_('..i..')','',player)
                else
                    up.ui:show('tech_jinyong_('..i..')','',player)
                end
            end
        end)
    else
        up.ui:hide('tech','',player)
    end
end

local function link_skill(player,unit)
    local id = 0
    player.show_skill_list = {}
    for skill in unit:each_skill('Hero') do
        id = id + 1
        local ui_btn = 'skill_btn_'..(id)
        local ui_ico = 'skill_icon_'..(id)
        up.ui:show(ui_btn,'',player)
        up.ui:show(ui_ico,'',player)
        up.ui:show('hot_key_'..(id),'',player)
        up.ui:show('skill_aband_'..(id),'',player)
        up.ui:show('learn_'..(id),'',player)
        up.ui:show('skill_cd_'..(id),'',player)
        up.ui:show('skill_out_of_mana_'..(id),'',player)
        up.ui:show('skill_stack_'..(id),'',player)
        up.ui:bind_skill(ui_btn,skill,player)
        table.insert(player.show_skill_list,skill)
        --show stack count
        if skill:get('ability_max_stack_count') == 0 then
            up.ui:hide('skill_stack_'..(id),'',player)
        else
            up.ui:show('skill_stack_'..(id),'',player)
        end
        if id == 10 then
            return
        end
    end

    for skill in unit:each_skill('Common') do
        id = id + 1
        local ui_btn = 'skill_btn_'..(id)
        local ui_ico = 'skill_icon_'..(id)
        up.ui:show(ui_btn,'',player)
        up.ui:show(ui_ico,'',player)
        up.ui:show('hot_key_'..(id),'',player)
        up.ui:show('skill_aband_'..(id),'',player)
        up.ui:show('learn_'..(id),'',player)
        up.ui:show('skill_cd_'..(id),'',player)
        up.ui:show('skill_out_of_mana_'..(id),'',player)
        up.ui:show('skill_stack_'..(id),'',player)
        up.ui:bind_skill(ui_btn,skill,player)
        table.insert(player.show_skill_list,skill)
                --show stack count
        if skill:get('ability_max_stack_count') == 0 then
            up.ui:hide('skill_stack_'..(id),'',player)
        else
            up.ui:show('skill_stack_'..(id),'',player)
        end
        if id == 10 then
            return
        end
    end


    if id < 10 then
        for i = id + 1,10 do
            up.ui:hide('skill_btn_'..(i),'',player)
            --up.ui:unbind_skill('skill_btn_'..(i),player)
            --up.ui:bind_skill('skill_btn_'..(i),nil,player)
            up.ui:hide('skill_icon_'..(i),'',player)
            up.ui:hide('hot_key_'..(i),'',player)
            up.ui:hide('skill_aband_'..(i),'',player)
            up.ui:hide('learn_'..(i),'',player)
            up.ui:hide('skill_cd_'..(i),'',player)
            up.ui:hide('skill_out_of_mana_'..(i),'',player)
            up.ui:hide('skill_stack_'..(i),'',player)
        end
    end
end

--  MutiTargetSelectHandler
local function select_unitgroup(player,group)
    local unit = group[1]
    player.select_group = group
    player.select_group_i = 1
    player.select_unit = unit
    if player._attr_timer then
        player._attr_timer:remove()
    end

    local hide_ui = {
        'single_unit',
        'choose_unit_icon',
        'main_des',
        'DestructiblePanel',
        'lv_panel',
    }
    for _,ui in pairs(hide_ui) do
        up.ui:hide(ui,'',player)
    end

    local show_ui = {
        'mutl_unit',
        'attribute_panel',
        'skill_panel',
        'hp_bar',
        'mp_bar',
        'Role',
        'bagBtn',
    }
    for _,ui in pairs(show_ui) do
        up.ui:show(ui,'',player)
    end

    link_skill(player,unit)
    group_refresh(player,group)
    link_tech(player,unit)
    --work_refresh(player,unit)
    if player._attr_timer then player._attr_timer:remove() end
    player._attr_timer = up.loop(0.033,function()
        group_refresh(player,player.select_group)
    end)
end


--  SingleTargetSelectHandler
local function select_unit(player,unit)
    if unit:is_shop() then
        if not unit.is_ReSelect then
            if player.now_shop ~= unit then
                if player.select_unit then
                    player.select_unit.is_ReSelect = true
                    player:select(player.select_unit,true)
                else
                    up.ui:hide('Role','',player)
                end
                up.game:event_dispatch('Player-OpenShop',player,unit)
                return
            end
        end
    end
    if unit == player.select_unit then
        if unit.is_ReSelect then
            unit.is_ReSelect = false
        end
    end
    player.select_unitgroup = nil
    player.select_unit = unit
    player.select_target = unit

     local hide_ui = {
        'mutl_unit',
        'choose_unit_icon',
        'main_des',
        'DestructiblePanel',
    }
    if not unit:is_hero() then
        table.insert(hide_ui,'exp_bar')
    end
    for _,ui in pairs(hide_ui) do
        up.ui:hide(ui,'',player)
    end

    local show_ui = {
        'single_unit',
        'attribute_panel',
        'skill_panel',
        'hp_bar',
        'mp_bar',
        'choose_unit_showroom',
        'name_panel',
        'choose_unit_name',
        'Role',
        'bagBtn',
        'lv_panel',
    }
    if unit:is_hero() then
        table.insert(show_ui,'exp_bar')
    end
    for _,ui in pairs(show_ui) do
        up.ui:show(ui,'',player)
    end
    
    control_refresh(player,unit)
    if unit:get_owner() ~= player then
        up.ui:hide('skill_panel','',player)
        return
    end

    link_skill(player,unit)
    link_tech(player,unit)
    
    --work_refresh(player,unit)
end


local function set_main_unit(player,i)
    local group = player.select_group
    local unit = player.select_group[i]
    if player.select_unit == unit then
        player:select(unit)
        return
    end
    player.select_unit = unit
    player.select_group_i = i

    link_skill(player,unit)
    group_refresh(player,group)
end

local minimapscale = {1.0,1.0}
up.game:event('UI-Event', function(self, player,event)
    for i = 1,16 do
        if event == 'TouchStart_'..i then
            if not player.select_group then return end
            set_main_unit(player,i)
            return
        end
    end
    for i = 1,6 do
        if event == 'ClickHero_'..i then 
            player:select(player.herolist[i])
            return
        end
    end
    if event == 'CameraToUnit' then
        if gameapi.camera_is_following_target() == false then
            player:camera_focus(player.select_target)
            up.game:event('Mouse-LeftRelease',function (t,i_player)
                if player == i_player then
                    player:camera_unfocus()
                end
                t:remove()
            end)
        end
    end
    if event == 'focus_btn_click' then
        if minimapscale[1] == 0.2 then return end
        minimapscale = {minimapscale[1] - 0.2,minimapscale[2] - 0.2}
        up.ui:set_scale('mini_map_1',minimapscale ,player)
    end
    if event == 'defocus_btn_click' then
        if minimapscale[1] == 1.0 then return end
        minimapscale = {minimapscale[1] + 0.2,minimapscale[2] + 0.2}
        up.ui:set_scale('mini_map_1',minimapscale,player)
    end
end)

up.game:event('Unit-MutiSelect',function (_,player,group)
    if #group == 1 then
        select_unit(player,group[1])
    else
        select_unitgroup(player,group)
    end
end)

up.game:event('Unit-SingleSelect',function(_,player,unit)
    select_unit(player,unit)
end)

up.game:event('Keyboard-Down',function(_,player,key)
    if key == KEY['TAB'] then
        if not player.select_group then return end
        if #player.select_group == player.select_group_i then
            set_main_unit(player,1)
        else
            set_main_unit(player,player.select_group_i + 1)
        end
    end
    if key == KEY['B'] and player.select_target == player.select_unit then
        up.ui:show('bag','',player)
    end
end)

up.game:event('Skill-Get',function(_,skill)
    local unit = skill:get_owner()
    local player = unit:get_player()

    if player.select_unit == unit then
        link_skill(player,unit)
    end
end)

up.game:event('Skill-Lose',function(_,skill)
    local unit = skill:get_owner()
    local player = unit:get_player()

    if player.select_unit == unit then
        link_skill(player,unit)
    end
end)

up.game:event('Skill-Replace',function(_,skill)
    local unit = skill:get_owner()
    local player = unit:get_player()
    if player.select_unit == unit then
        link_skill(player,unit)
    end
end)