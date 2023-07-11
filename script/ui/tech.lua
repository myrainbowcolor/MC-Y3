
local function tech_level_up(player,i)
    local unit = player.select_unit
    local tech = unit:get_tech_index(i)
    local level = player:get_tech_level(tech)
    local must = player:check_tech_precondition(tech)
    local level_max = up.get_tech_max_level(tech)
    local is_max = level == level_max
    if is_max then
        gameapi.show_msg_to_role(player._base, "[System Info]This Tech is full", false)
        return
    end
    --if not player.tech_percondition_cache[tech] then
    --    gameapi.show_msg_to_role(player._base, "[System Info]未满足前置Conditions", false)
    --    return
    --end
    if must then
        for _,key in ipairs(RoleResKey) do
            local cost = up.get_tech_cost_res(tech,level+1,key) or 0
            if player:get(key) >= cost then
                player:add(key,-cost)
            else
                gameapi.show_msg_to_role(player._base, "[System Info]Insufficient Resources Held", false)
                return
            end
        end
        if level + 1 == level_max then
            up.ui:hide("button_("..i..")",'',player)
        end
        player:add_tech_level(tech,1)
    end
end

local tech_tips_cost_ico = {
    [1] = "TipsGoldIcon_tech",
    [2] = "0f751776-25ec-4a30-9eec-1c11830ec2e3",
    [3] = "05d1261d-f373-454a-a4f0-6d31dc11ae87"
}
local tech_tips_cost_txt = {
    [1] = "TipsGold_tech",
    [2] = "1b711f23-3b58-46e9-9a32-d58ad735b220",
    [3] = "886a4c2f-ab7a-4efa-a501-b2eb24bbf6cb"
}

local function show_tech_tips(player,i)
    up.ui:show('Tips_tech','',player)
    local unit = player.select_unit
    if not unit then
        return
    end
    local tech = unit:get_tech_index(i)
    local update = function()
        local level = player:get_tech_level(tech) + 1
        local level_max = up.get_tech_max_level(tech)
        local is_max = level - 1 == level_max
        local name = up.get_tech_name(tech)
        local desc = up.get_tech_desc(tech)
        local icon = up.get_tech_icon(tech,level)
        --local gold = 0
        local dis = player:check_tech_precondition(tech)
        if dis then
            up.ui:hide('TipsDis_tech','',player)
            if is_max == false then
                for i=1,3 do
                    if RoleResKey[i] then
                        local price_gold = up.get_tech_cost_res(tech,level,RoleResKey[i])
                        if price_gold and price_gold > 0 then
                            up.ui:show(tech_tips_cost_ico[i],'',player)
                            up.ui:set_image(tech_tips_cost_ico[i], up.get_res_icon(RoleResKey[i]), player)
                            
                            if player:get(RoleResKey[i]) >= price_gold then
                                up.ui:set_text(tech_tips_cost_txt[i], string.format("%d",tostring(price_gold)), player)
                            else
                                up.ui:set_text(tech_tips_cost_txt[i], '#ff0000'..string.format("%d",tostring(price_gold)), player)
                            end
                        else
                            up.ui:hide(tech_tips_cost_ico[i],'',player)
                        end
                    else
                        up.ui:hide(tech_tips_cost_ico[i],'',player)
                    end
                end
            else
                --up.ui:set_text('TipsDis_tech','This technology has reached full level',player)
            end
        end
        up.ui:set_text('TipsName_tech', 'Research「'..name..'」', player)
        up.ui:set_text('TipsDesc_tech', desc, player)
        up.ui:set_text('TipsLevel_tech', 'Lv.'..level, player)
        --up.ui:set_text('TipsGold_tech', price_gold, player)
        up.ui:set_image('TipsIcon_tech', icon, player)
    end
    update()
    if player.__updateTechTips then player.__updateTechTips:remove() end
    player.__updateTechTips = up.loop(0.03,function()
        update()
    end)
end

up.game:event('UI-Event', function(self, player,event)
    --tech tips
    for i = 1,6 do
        if event == 'techtips_show_'..i then
            show_tech_tips(player,i)
            return
        end
        if event == 'techtips_hide_'..i then
            up.ui:hide('Tips_tech','',player)
            player.__updateTechTips:remove()
            return
        end
        if event == 'tech_click_'..i then
            tech_level_up(player,i)
            return
        end
    end
end)
