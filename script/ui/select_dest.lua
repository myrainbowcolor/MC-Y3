
up.game:event('Destructible-Select',function (_,player,dest)
    local hide_ui = {
        'attribute_panel',
        'lv_panel',
        'hp_bar',
        'mp_bar',
        'mutl_unit',
        'choose_unit_showroom',
        'skill_panel',
        'exp_bar',
        'bagBtn',
        'bag',
        'Role',
        'lv_panel',
        'choose_unit_icon(1)',
        "0682a7eb-56b0-4a10-9924-fe0d0ff2b9ab",
    }
    for _,ui in pairs(hide_ui) do
        up.ui:hide(ui,'',player)
    end

    local show_ui = {
        'name_panel',
        'choose_unit_ico',
        'main_des',
        'DestructiblePanel',
        'res_bar',
        'choose_dest_showroom',
        'hero_icon_mask(1)',
    }
    for _,ui in pairs(show_ui) do
        up.ui:show(ui,'',player)
    end
    player.select_unitgroup = nil
    player.select_unit = nil
    player.select_target = dest
    if dest:get_res() > 0 then
        up.ui:show('res_bar','',player)
    else
        up.ui:hide('res_bar','',player)
    end
    up.ui:set_text('choose_dest_name',dest:get_name(),player)
    up.ui:set_text('main_des',dest:get_desc(),player)
    up.ui:set_text('dest_res_txt',dest:get_res(),player)
    --up.ui:set_text('dest_res_title','Coin',player)
    --up.ui:set_image('dest_res_ico',player:get_res_icon('Coin'),player)
    up.ui:set_model('choose_dest_showroom',dest:get_model(),player)

    if player._updateAttrTimer then player._updateAttrTimer:remove() end
    player._updateAttrTimer = up.loop(0.033,function()
        if not dest or not dest:is_alive() then
            up.ui:hide('DestructiblePanel','',player)
            if player._updateAttrTimer then player._updateAttrTimer:remove() end
        end
        up.ui:set_text('dest_res_txt',dest:get_res(),player)
    end)
end)
