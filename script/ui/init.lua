
require 'ui.select_unit'
require 'ui.select_item'
require 'ui.select_dest'
require 'ui.tips'
require 'ui.shop'
require 'ui.tech'
require 'ui.back_game'
--ui init
up.wait(0.033,function()

    local player_table = {}
    for i = 1 , 30 do 
        if gameapi.get_role_by_int(i) then
            table.insert(player_table,up.player(i))
        end
    end
    --init
    RoleResKey = up.get_all_resType(true)
    for _,v in pairs (player_table) do
        local player = v

        up.ui:set_prefab_ui_visible(player,false)
        for i=1,3 do
            if RoleResKey[i] then
                up.ui:set_image('currencyIco_'..i,up.get_res_icon(RoleResKey[i]),player)
                --up.ui:set_image('TipsGoldIcon_tech',up.get_res_icon('Coin'),player)
                --up.ui:set_image('TipsItem_2',up.get_res_icon('Coin'),player)
            else
                up.ui:hide('currency_'..i,'',player)
            end
        end
        local hide_ui = {
            'attribute_panel',
            'choose_unit_name',
            'choose_unit_showroom',
            'mutl_unit',
            'hp_bar',
            'mp_bar',
            'tech',
            'Tips'
        }
        for _,ui in pairs(hide_ui) do
            up.ui:hide(ui,'',player)
        end

        --update
        up.loop(0.033,function()
            for i=1,3 do
                if RoleResKey[i] then
                    
                    up.ui:set_text('currencyText_'..i,string.format('%d',tostring(player:get(RoleResKey[i]))),player)
                    up.ui:set_image('currencyIco_'..i,up.get_res_icon(RoleResKey[i]),player)
                end
            end


            local t_hour = string.gsub(string.sub(up.get_game_time(),1,2),'%.','')
            local t_min = string.format("%d",tonumber(string.sub(string.format("%.2f", up.get_game_time()),-2,-1)*60/100))
            if	string.len(t_min) == 1 then
                t_min = "0" .. t_min
            end
            if tonumber(t_hour) >= 6 and tonumber(t_hour) <= 18 then
                up.ui:set_image('image_188',106328,player)
            else
                up.ui:set_image('image_188',106325,player)
            end 
            local time = t_hour..":"..t_min
                
            up.ui:set_text('time_txt',time,player)
            for i=1,6 do
                if not player.herolist then return end
                local hero = player.herolist[i]
                if hero then
                    up.ui:show('hero_list_'..(i),'',player)
                    up.ui:set_progress('hero_mp_bar_'..(i),hero:get'mp_max',hero:get'mp_cur',player)
                    if hero:is_alive() then
                        up.ui:hide('Hero_head_dead_'..(i),'',player)
                    else
                        up.ui:show('Hero_head_dead_'..(i),'',player)
                        up.ui:set_progress('hero_mp_bar_'..(i),hero:get'mp_max',0,player)
                    end
                    up.ui:set_text('Hero_name_'..(i),hero:get_name(),player)
                    up.ui:set_image('Hero_head_img_'..(i),hero:get_icon(),player)
                    up.ui:set_progress('hero_hp_bar_'..(i),hero:get'hp_max',hero:get'hp_cur',player)
                else
                    up.ui:hide('hero_list_'..(i),'',player)
                end
            end
        end)
    end
end)

up.game:event('Unit-Create',function(_,unit)
    if not unit then
        --print(debug.traceback('------Unit-Create------'))
    end
    local player = unit:get_owner()
    if not player.herolist then player.herolist = {} end
    if unit:is_hero() then
        --unit.skill_point = unit:get_level()
        table.insert(player.herolist,unit)
    end
end)

up.game:event('Unit-Delete',function (_,unit)
    local player = unit:get_owner()
    if not player.herolist then return end
    if not unit:is_hero() then return end
    table.removeValue(player.herolist,unit)
end)
