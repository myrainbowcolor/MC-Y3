up.ui = {}


up.ui.consle_tbl = {}

up.ui.event = {}

local n = 0

function up.ui:show(name,anim,player)
    if anim == 'ease' then
        local a = 0
        GameAPI.show_ui_comp_animation(player._base,name,anim)
        up.ui:set_opacity(name,0,player)
        up.loop(0.033,function(t)
            if a <= 20 then
                a = a + 1
                up.ui:set_opacity(name,a*5*0.01,player)
            else
                t:remove()
            end
        end)
    else
        GameAPI.show_ui_comp_animation(player._base,name,anim)
    end
end

function up.ui:hide(name,anim,player)
    GameAPI.hide_ui_comp_animation(player._base,name,anim)
    up.game:event_dispatch('UI-Hide',name,player)
    -- if anim == 'ease' then
    --     local a = 0
    --     up.loop(0.033,function(t)
    --         if a <= 33 then
    --             a = a + 1
    --             up.ui:set_opacity(name,1 - a*3*0.01,player)
    --         else
    --             GameAPI.hide_ui_comp_animation(player._base,name,anim)
    --             t:remove()
    --         end
    --     end)
    -- else
    --     GameAPI.hide_ui_comp_animation(player._base,name,anim)
    -- end
end

function up.ui:set_hotkey(name,key,player)
    if KEY[key] then key = KEY[key] end
    GameAPI.set_btn_short_cut(player._base,name,key)
end

--  Set the default main interface UI display and hide
function up.ui:set_prefab_ui_visible(player,flag)
    GameAPI.set_prefab_ui_visible(player._base,flag)
end

function up.ui:set_position(name,position,player)
    GameAPI.set_ui_comp_pos(player._base,name,position[1],position[2])
end

function up.ui:set_size(name,size,player)
    GameAPI.set_ui_comp_size(player._base,name,size[1],size[2])
end

function up.ui:set_scale(name,scale,player)
    GameAPI.set_ui_comp_scale(player._base,name,scale[1],scale[2])
end

function up.ui:active_skill(name,bool,player)
    GameAPI.set_skill_btn_action_effect(player._base, name,bool) 
end



function up.ui:set_z_order(name,z_order,player)
    GameAPI.set_ui_comp_z_order(player._base,name,z_order)
end

function up.ui:set_image(name,image_id,player)
    GameAPI.set_ui_comp_image(player._base,name,image_id)
end

function up.ui:set_progress(name,max,cur,player)
    GameAPI.set_progress_bar_max_value(player._base,name,max)
    GameAPI.set_progress_bar_current_value(player._base,name,cur)
    
end

function up.ui:set_max_value(name,max_value,player)
    GameAPI.set_progress_bar_max_value(player._base,name,max_value)
end

function up.ui:set_cur_value(name,current_value,player)
    GameAPI.set_progress_bar_current_value(player._base,name,current_value)
end


function up.ui:set_enable(name,enable,player)
    GameAPI.set_ui_comp_enable(player._base,name,enable)
end

function up.ui:set_text(name,txt,player)
    GameAPI.set_ui_comp_text(player._base,name,tostring(txt))
end

function up.ui:set_font_size(name,font_size,player)
    GameAPI.set_ui_comp_font_size(player._base,name,font_size)
end

function up.ui:set_opacity(name,opacity,player)
    GameAPI.set_ui_comp_opacity(player._base,name,opacity)
end

function up.ui:unbind_skill(name,player)
    GameAPI.cancel_bind_skill(player._base,name)
end

function up.ui:bind_skill(name,skill,player)
    GameAPI.set_skill_on_ui_comp(player._base,skill._base,name)
end

function up.ui:bind_buff(name,unit,player)
    GameAPI.set_skill_on_ui_comp(player._base,unit._base,name)
end

function up.ui:bind_item(name,item,player)
    GameAPI.set_skill_on_ui_comp(player._base,item._base,name)
end

function up.ui:bind_item_tbl(name,unit,slot_type,slot,player)
    GameAPI.set_ui_comp_unit_slot(player._base,name,unit._base,SlotType[slot_type],slot)
end

function up.ui:set_ui_comp_slot(player,name,slot_type,slot)
    GameAPI.set_ui_comp_slot(player._base,name,SlotType[slot_type],slot)
end

function up.ui:set_model(name,model,player)
    GameAPI.set_ui_model_id(player._base,name,model)
end

--===================EG===================-

-- 停止UI时间轴的动画
--- @param id integer 定义时间轴动画的先后顺序,参考单位id
--- @param player Player
--- @param speed number|nil
--- @param circulation boolean|nil
function up.ui:play_ui_comp_anim(player, id, speed, circulation)
    gameapi.play_ui_comp_anim(player._base, id, speed or 1.0, circulation or false)
end


-- 播放UI时间轴动画
--- @param id integer 定义时间轴动画的先后顺序,参考单位id
--- @param player Player
function up.ui:stop_ui_comp_anim(player, id)
    gameapi.stop_ui_comp_anim(player._base, id)
end