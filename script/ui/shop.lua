
local function refresh_shop_tab(player,tab_idx)
    local n = 0
    if not player.now_shop or not player.now_shop:is_alive() then
        up.ui:hide('shop_panel','',player)
        player.now_shop = nil
        if player.shop_timer then player.shop_timer:remove() end
        return
    end
    for key in player.now_shop:each_goods(tab_idx) do
        n = n + 1
        up.ui:show('goods_'..n,'',player)
        up.ui:set_image('goods_icon_'..n,up.get_item_icon(key),player)
        up.ui:set_text('goods_cnt_'..n,string.format('%d',player.now_shop:get_shop_item_stock(tab_idx,key)),player)
        up.ui:set_text('goods_cost_'..n,'',player)
        local l_time = player.now_shop:get_shop_item_cd(tab_idx,key)
        if l_time then
            up.ui:show('goods_cd_'..n,'',player)
            up.ui:set_progress('goods_cd_'..n,l_time[2],l_time[1],player)
        else
            up.ui:hide('goods_cd_'..n,'',player)
        end
    end
    for i = n+1,31 do
        up.ui:hide('goods_'..i,'',player)
    end
end
local shop_money_value = {
    [1] = "TipsItem_3",
    [2] = "TipsItem_5",
    [3] = 'e45e07ce-6b51-420a-b282-f40ad875d3f6'
}
local shop_money_icon = {
    [1] = "TipsItem_2",
    [2] = "TipsItem_4",
    [3] = 'a0d5d56d-9f20-4939-84ff-57310ef3eef0'
}
local function show_item_tips(player,item)
    if not item then return end
    up.ui:show('shop_tips','',player)
    up.ui:show('TipsItem_1','',player)
    local name = up.get_item_name(item)
    local desc = up.get_item_desc(item)
    --local lv = item:get_level()
    local icon = up.get_item_icon(item)
    --local price_gold = up.get_item_buy_price(item,'Coin')
    for i=1,3 do
        if RoleResKey[i] then
            local price_gold = up.get_item_buy_price(item,RoleResKey[i])
            if price_gold > 0 then
                up.ui:show(shop_money_icon[i],'',player)
                up.ui:set_image(shop_money_icon[i], up.get_res_icon(RoleResKey[i]), player)
                up.ui:set_text(shop_money_value[i], string.format('%d',price_gold), player)
            else
                up.ui:hide(shop_money_icon[i],'',player)
            end
        else
            up.ui:hide(shop_money_icon[i],'',player)
        end
    end
    up.ui:set_text('TipsName_1', name, player)
    up.ui:set_text('TipsDesc_1', desc, player)
    --up.ui:set_text('TipsLevel_1', 'Lv.'..lv, player)
    up.ui:set_image('TipsIcon_1', icon, player)
end

local function show_sell_item_tips(player,item)
    up.ui:show('shop_tips','',player)
    up.ui:hide('TipsItem_1','',player)
    local name = up.get_item_name(item)
    local desc = up.get_item_desc(item)
    --local lv = item:get_level()
    local icon = up.get_item_icon(item)
    up.ui:set_text('TipsName_1', name, player)
    up.ui:set_text('TipsDesc_1', desc, player)
    up.ui:set_image('TipsIcon_1', icon, player)
    for i=1,3 do
        if RoleResKey[i] then
            local price_gold = up.get_item_buy_price(item,RoleResKey[i])
            if price_gold > 0 then
                up.ui:show(shop_money_icon[i],'',player)
                up.ui:set_image(shop_money_icon[i], up.get_res_icon(RoleResKey[i]), player)
                up.ui:set_text(shop_money_value[i], string.format('%d',price_gold), player)
            else
                up.ui:hide(shop_money_icon[i],'',player)
            end
        else
            up.ui:hide(shop_money_icon[i],'',player)
        end
    end
end

local function update_shop_sell_item(player)
    local unit = player.select_target
    if not unit or unit:get_owner() ~= player then
        up.ui:hide('sell','',player)
        return
    else
        up.ui:show('sell','',player)
    end
    for i=1,6 do
        up.ui:set_image('sell_item_icon_'..i,100485,player)
        up.ui:set_text('sell_item_stack_'..i,'',player)
        up.ui:set_text('sell_item_cost_'..i,'',player)
    end
    if not player.select_target or not player.select_target:is_alive() then
        if player.shop_timer then player.shop_timer:remove() end
        return
    end
    local unit = player.select_target
    for i=1,6 do
        local item = unit:get_item('Inventory',i)
        if item then
            up.ui:set_image('sell_item_icon_'..i,item:get_icon(),player)
            up.ui:set_text('sell_item_stack_'..i,string.format('%d',item:get_stack()),player)
            --up.ui:set_text('sell_item_cost_'..i,item:get_buy_price('Coin'),player)
        end
    end
end

up.game:event('Player-OpenShop',function(_,player,unit)
    local tab_cnt = unit:get_shop_tab_cnt()
    if tab_cnt <= 0 then return end
    --get all tab
    player.shop_tab = 1
    player.shop_tab_add = 0
    player.now_shop = unit
    up.ui:show('shop_panel','',player)
    --get all tab
    for i = 1,30 do
        up.ui:hide('goods_'..i,'',player)
    end
    local tab_cnt = unit:get_shop_tab_cnt()
    for i = 1,4 do
        if i > tab_cnt then
            up.ui:hide('tab_'..i,'',player)
        else
            up.ui:show('tab_'..i,'',player)
            up.ui:set_text('tab_name_'..i,unit:get_shop_tab_name(i),player)
            up.ui:set_text('tab_light_name_'..i,unit:get_shop_tab_name(i),player)
            up.ui:hide('tab_light_'..i,'',player)
            up.ui:show('tab_name_'..i,'',player)
        end
    end
    --hightlight the first
    up.ui:show('tab_light_'..player.shop_tab,'',player)
    up.ui:hide('tab_name_'..player.shop_tab,'',player)
    if player.shop_timer then
        player.shop_timer:remove()
    end
    refresh_shop_tab(player,player.shop_tab)
    update_shop_sell_item(player)
    player.shop_timer = up.loop(0.03,function ()
        refresh_shop_tab(player,player.shop_tab)
        update_shop_sell_item(player)
    end)
end)

local buy_item = function(player,i)
    if not player.select_target then return end
    local target = player.select_target
    print(target)
    local shop = player.now_shop
    local range = shop:get_shop_range()
    local item = shop:get_shop_tab_goods_key(player.shop_tab,i)
    if target:is_alive() and shop:is_alive() then
        if target:get_point() * shop:get_point() > range then
            player:msg("[System Information] You are too far away")
            return
        end
    else
        if not target:is_alive() then
            player:msg("[System Information] No targets available")
        else
            player:msg("[System Information] No shop available")
        end
        return
    end

    for _,key in ipairs(RoleResKey) do
        local price_gold = up.get_item_buy_price(item,key)
        if player:get(key) < price_gold then
            player:msg("[System Information] Insufficient currency")
            return
        end
    end
    if not player:check_item_precondition(item) then
        gameapi.show_msg_to_role(player._base, "[System Information] Preconditions not met", false)
        return
    end

    if target.type == 'unit' and target:get_owner() == player then
        target:buy_item(shop,player.shop_tab,shop:get_shop_tab_goods_key(player.shop_tab,i))
    end


end

--update tab
local update_tab = function(player)
    local unit = player.now_shop
    local tab_cnt = unit:get_shop_tab_cnt()
    local add = player.shop_tab_add
    if tab_cnt <= 0 then return end
    for i = 1,4 do
        if i + add > tab_cnt then
            up.ui:hide('tab_'..i,'',player)
        else
            up.ui:show('tab_'..i,'',player)
            up.ui:set_text('tab_name_'..i,unit:get_shop_tab_name(i+add),player)
            up.ui:set_text('tab_light_name_'..i,unit:get_shop_tab_name(i+add),player)
            up.ui:hide('tab_light_'..i,'',player)
            up.ui:show('tab_name_'..i,'',player)
        end
    end
    if player.shop_tab > add then
        up.ui:show('tab_light_'..player.shop_tab - add,'',player)
        up.ui:hide('tab_name_'..player.shop_tab - add,'',player)
    end
    refresh_shop_tab(player,player.shop_tab)
end

local sell_item = function(player,item)
    if not player.select_target then return end
    if not item then return end
    local target = player.select_target
    local shop = player.now_shop
    local range = shop:get_shop_range()
    if target:is_alive() and shop:is_alive() then
        if target:get_point() * shop:get_point() > range then
            player:msg("[System Information] You are too far away")
            return
        end
    else
        if not target:is_alive() then
            player:msg("[System Information] No targets available")
        else
            player:msg("[System Information] No shop available")
        end
        return
    end
    target:sell_item(shop,item)
end

up.game:event('UI-Event', function(self, player,event)
    --Mouse Right Click :buy
    for i = 1,30 do
        if event == 'TouchRightClick_'..i then
            buy_item(player,i)
            return
        end
    end
    --Mouse Right Click :Sell
    for i = 1,6 do
        if event == 'TouchRightClick_'..(i+30) then
            local item = player.select_unit:get_item('Inventory',i)
            sell_item(player,item)
            return
        end
    end
    --MouseEnter shop Item
    for i = 2,31 do
        if event == 'MouseEnter_'..i then
            show_item_tips(player,player.now_shop:get_shop_tab_goods_key(player.shop_tab,i-1))
            return
        end
    end
    --MouseEnter sell item
    for i = 1,6 do
        if event == 'sell_item_show_'..i then
            if player.select_unit then
                local item = player.select_unit:get_item('Inventory',i)
                if item then
                    show_sell_item_tips(player,item:get_id())
                end
            end
            return
        end
    end
    --MouseLeave_ shop Item
    for i = 2,37 do
        if event == 'MouseLeave_'..i then
            up.ui:hide('shop_tips','',player)
            return
        end
    end
    --change shop tab
    for i = 1,4 do
        if event == 'shop_tab_'..i then
            up.ui:hide('tab_light_'..player.shop_tab - player.shop_tab_add,'',player)
            up.ui:show('tab_name_'..player.shop_tab - player.shop_tab_add,'',player)
            player.shop_tab = i
            up.ui:show('tab_light_'..i,'',player)
            up.ui:hide('tab_name_'..i,'',player)
            refresh_shop_tab(player,player.shop_tab)
            return
        end
    end
    --close shop
    if event == 'close_shop' then
        if player.shop_timer then player.shop_timer:remove() end
        player.now_shop = nil
        return
    end
    --tab click last
    if event == 'shop_tab_down' then
        if player.shop_tab_add > 0 then
            player.shop_tab_add = player.shop_tab_add - 1
            update_tab(player)
        end
        return
    end
    --tab click next
    if event == 'shop_tab_up' then
        local unit = player.now_shop
        local tab_cnt = unit:get_shop_tab_cnt()
        if player.shop_tab_add < tab_cnt - 4 then
            player.shop_tab_add = player.shop_tab_add + 1
            update_tab(player)
        end
        return
    end
    --MouseLeave sell Item
    for i = 1 ,6 do
        if event == 'sell_item_hide_'.. i then
            up.ui:hide('shop_tips','',player)
            return
        end
    end
    --MouseEnter Inventory
    for i = 32 ,37 do
        if event == 'MouseEnter_'..i then
            if player.select_unit then
                local item = player.select_unit:get_item('Inventory',i - 31)
                if item then
                    show_sell_item_tips(player,item:get_id())
                end
            end
            return
        end
    end
end)

