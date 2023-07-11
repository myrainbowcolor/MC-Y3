
local function update_skill_tips(player,skill)
    if not player.select_unit then return end
    up.ui:show('Tips','',player)
    up.ui:show('TipsCost','',player)
    up.ui:show('TipsLevel','',player)
    up.ui:hide('TipsItem_sell','',player)
    --local skill = player.show_skill_list[i]
    if not skill then return end
    local name = skill:get_name()
    local desc = skill:get'desc'
    local lv = string.format('%d',skill:get_level())
    local cd = string.format('%.2f', skill:get'cd')
    local cost = string.format('%d',skill:get'cost')
    local icon = skill:get_icon()
    up.ui:set_text('TipsName', name, player)
    up.ui:set_text('TipsDesc', desc, player)
    up.ui:set_text('TipsLevel', 'Lv.'..lv, player)
    if cd == 0 then
        up.ui:set_text('TipsCool', '', player)
    else
        up.ui:set_text('TipsCool', cd..'S', player)
    end
    if cost == 0 or skill:get_cast_type() == 'Passive' then
        up.ui:set_text('TipsCost', '', player)
    else
        up.ui:set_text('TipsCost', cost..'MP', player)
    end
    up.ui:set_image('TipsIcon', icon, player)
end

local function show_skill_tips(player,i)
    if not player.select_unit then return end
    up.ui:show('Tips','',player)
    up.ui:show('TipsCost','',player)
    up.ui:show('TipsLevel','',player)
    up.ui:hide('TipsItem_sell','',player)
    local skill = player.show_skill_list[i]
    if not skill then return end
    player.now_skill_tips = skill
    update_skill_tips(player,skill)
end

local TipsItem_Gold = {
    [1] = "TipsItem_Gold",
    [2] = "40f3bdb2-ae09-4680-9517-b158581391ed",
    [3] = '0a1a539f-4914-4aff-a3a4-e4844f105613'
}
local TipsItem_GoldIcon = {
    [1] = "TipsItem_GoldIcon",
    [2] = "c12284ef-4d8a-437e-9e21-37c4945649f1",
    [3] = 'd3e2b0d8-b0b4-4fc1-93da-21045072d678'
}
local function show_item_tips(player,type,i)
    if not player.select_unit then return end
    if type == 'Inventory' then
        up.ui:show('Tips','',player)
        up.ui:hide('TipsCost','',player)
        up.ui:hide('TipsLevel','',player)
        up.ui:hide('TipsItem_sell','',player)
        local item = player.select_unit:get_item(type,i)
        if not item then return end
        local name = item:get_name()
        local desc = item:get_desc()
        local lv = string.format('%d',item:get_level())
        local icon = item:get_icon()

        up.ui:set_text('TipsName', name, player)
        up.ui:set_text('TipsDesc', desc, player)
        up.ui:set_text('TipsCool', 'Lv.'..lv, player)
        --up.ui:set_text('TipsItem_Gold', price_gold, player)
        up.ui:set_image('TipsIcon', icon, player)
        --[[
        for i=1,3 do
            if RoleResKey[i] then
                local price_gold = item:get_buy_price(RoleResKey[i])
                if price_gold > 0 then
                    up.ui:show(TipsItem_GoldIcon[i],'',player)
                    up.ui:set_image(TipsItem_GoldIcon[i], up.get_res_icon(RoleResKey[i]), player)
                    up.ui:set_text(TipsItem_Gold[i]..i, price_gold, player)
                else
                    up.ui:hide(TipsItem_GoldIcon[i],'',player)
                end
            else
                up.ui:hide(TipsItem_GoldIcon[i],'',player)
            end
        end]]
    elseif type == 'Bag' then
        up.ui:show('shop_tips','',player)
        up.ui:show('TipsItem_1','',player)
        --up.ui:show('TipsItem_sell','',player)
        local item = player.select_unit:get_item(type,i)
        if not item then return end
        local name = item:get_name()
        local desc = item:get_desc()
        local lv = string.format('%d',item:get_level())
        local icon = item:get_icon()
        local price_gold = string.format('%d',item:get_buy_price'Coin')
        up.ui:set_text('TipsName_1', name, player)
        up.ui:set_text('TipsDesc_1', desc, player)
        up.ui:set_text('TipsLevel_1', lv, player)
        up.ui:set_text('TipsItem_3', price_gold, player)
        up.ui:set_image('TipsIcon_1', icon, player)
    end
end

local function show_buff_tips(player,i)
    if not player.select_unit then return end
    up.ui:show('buff_tips','',player)

    local buff = player.select_unit:find_buff_index(i,true)
    local name = buff.name
    local desc = buff.desc
    local lv = ''
    if buff.skill then
        lv = 'Lv.'..string.format('%d',buff.skill:get_level())
    end
    local icon = buff.icon
    local source = buff.source
    local source_tips = ''
    if source then
        source_tips = source:get_owner():get_name()..'['..source:get_name()..']'
    end
    up.ui:set_image('buffIco', icon, player)
    up.ui:set_text('buffName', name, player)
    up.ui:set_text('buffDes', desc, player)
    up.ui:set_text('buffLv', lv, player)
    up.ui:set_text('buffOrigin', source_tips, player)
end



up.game:event('UI-Event', function(self, player,event)
    --print(event == 'skill_tips_show_1')
    for i = 1,36 do
        if event == 'in_bagItem_'..i then
            show_item_tips(player,'Bag',i)
            return
        end
    end
    for i = 1,10 do
        if event == 'skill_tips_show_'..i then 
            show_skill_tips(player,i)
            return
        end
    end
    for i = 1,6 do
        if event == 'show_item_tips_'..i then 
            show_item_tips(player,'Inventory',i)
            return
        end
    end
    for i = 1,10 do
        if event == 'bufftips_show_'..i then
            show_buff_tips(player,i)
            return
        end
        if event == 'bufftips_hide_'..i then
            up.ui:hide('buff_tips','',player)
            return
        end
    end
    for i = 1,50 do
        if event == 'None_'..i then
            up.ui:hide('Tips','',player)
            up.ui:hide('shop_tips','',player)
            return
        end
    end
end)

up.game:event('Skill-AttrChange',function(_,skill)
    local unit = skill:get_owner()
    local player = unit:get_player()
    if player.now_skill_tips == skill then
        update_skill_tips(player,skill)
    end
end)