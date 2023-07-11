local setmetatable = setmetatable
local math_floor = up.math.floor
local pairs = pairs

local mt = {}
mt.__index = mt
mt.type = 'unit'
up.unit_class = mt

local unitType = {
    'hero',
    'building',
    'unknown',
    'unit',
}

-- attr
local attrType = {
    ['hp_max'] = 'hp_max',
    ['hp_cur'] = 'hp_cur',
    ['mp_max'] = 'mp_max',
    ['mp_cur'] = 'mp_cur',
    ['hp_rec'] = 'hp_rec',
    ['mp_rec'] = 'mp_rec',
    ['ori_speed'] = 'ori_speed',
    ['attack_phy'] = 'attack_phy',
    ['defense_phy'] = 'defense_phy',
    ['pene_phy'] = 'pene_phy',
    ['pene_phy_ratio'] = 'pene_phy_ratio',
    ['vampire_phy'] = 'vampire_phy',
    ['attack_mag'] = 'attack_mag',
    ['defense_mag'] = 'defense_mag',
    ['pene_mag'] = 'pene_mag',
    ['pene_mag_ratio'] = 'pene_mag_ratio',
    ['vampire_mag'] = 'vampire_mag',
    ['attack_speed'] = 'attack_speed',
    ['critical_chance'] = 'critical_chance',
    ['critical_dmg'] = 'critical_dmg',
    ['cd_reduce'] = 'cd_reduce',
    ['hit_rate'] = 'hit_rate',
    ['dodge_rate'] = 'dodge_rate',
    ['extra_dmg'] = 'extra_dmg',
    ['dmg_reduction'] = 'dmg_reduction',
    ['gainvalue'] = 'gainvalue',
    ['resilience'] = 'resilience',
    ['heal_effect'] = 'heal_effect',
    ['body_size'] = 'body_size',
    ['alarm_range'] = 'alarm_range',
    ['cancel_alarm_range'] = 'cancel_alarm_range',
    ['vision_rng'] = 'vision_rng',
    ['vision_night'] = 'vision_night',
    ['rotate_speed'] = 'rotate_speed',
    ['strength'] = "strength",
    ['agility'] = "agility",
    ['intelligence'] = "intelligence",
    ['main'] = "main",
}

local abilityType = {
    ['Hide'] = 0,
    ['Normal'] = 1,
    ['Common'] = 2,
    ['Hero'] = 3,
    ['Item'] = 4,
    ['Magicbook'] = 5,
    ['Build'] = 6,
}

function mt:__tostring()
    return ('%s|%s|%s'):format('unit', self:get_name(), tostring(self._base))
end

function mt:lightning(data)
    return up.lightning(data)
end

function mt:set_name(name)
    self._base:api_set_name(name)
end

function mt:get_name()
    if self:is_destroyed() then
        return nil
    end
    return self._base:api_get_name()
end

function mt:get_type()
    if self:is_destroyed() then
        return nil
    end
    return unitType[self._base:api_get_type()]
end

function mt:get_key()
    if not self._base then
        return nil
    end
    if self:is_destroyed() then
        return nil
    end
    return self._base.api_get_key()
end

function mt:get_typeId()
    return self._base.api_get_key()
end

function mt:get_icon()
    if self:is_destroyed() then
        return nil
    end
    return gameapi.get_icon_id(self._base)
end

function mt:get_type_icon()
    if self:is_destroyed() then
        return nil
    end
    return GameAPI.get_icon_id_by_unit_type(self._base.api_get_key())
end

function mt:get_point()
    if self:is_destroyed() then
        return nil
    end
    local p = self._base:api_get_position()
    return up.actor_point(p)
end

function mt:get_owner()
    if self:is_destroyed() then
        return nil
    end
    return up.player(self._base:api_get_role():api_get_role_id())
end

-- 改变单位所属玩家
--- @param player Player
function mt:change_player(player)
    GameAPI.change_unit_role(self._base, player._base or player)
end

function mt:get_player()
    if self:is_destroyed() then
        return nil
    end
    return up.player(self._base:api_get_role():api_get_role_id())
end

function mt:add_item(item)
    local item = self._base:api_add_item(item)
    return item
end

function mt:get_skill_point()
    if self:is_destroyed() then
        return nil
    end
    return self._base:api_get_ability_point()
end

function mt:get_attack_speed()
    if self:is_destroyed() then
        return 0
    end
    local attack_skill = self:find_skill('Normal', nil, 1)
    if attack_skill then
        if self:get('attack_speed') == 0 then
            return 0
        else
            local as = self:get('attack_speed') / 100
            local cd = 1 / (attack_skill:get('cd') / as)
            return cd
        end
    else
        return false
    end
end

function mt:get_atk_range()
    if self:is_destroyed() then
        return 0
    end
    local attack_skill = self:find_skill('Normal', nil, 1)
    if attack_skill then
        return attack_skill:get('range')
    else
        return false
    end
end

function mt:add_item(item)
    if self:is_destroyed() then
        return
    end
    local item = up.actor_item(self._base:api_add_item(item))
    return item
end

-- function mt:attack_move(point)
--     api_release_command()
-- end

function mt:move(point)
    if self:is_destroyed() then
        return
    end
    self._base:api_release_command(GameAPI.create_unit_command_move_to_pos(point._base))
end

function mt:move_road(road, patrol_mode, can_attack)
    if self:is_destroyed() then
        return
    end
    self._base:api_release_command(GameAPI.create_unit_command_move_along_road(gameapi.get_road_point_list_by_res_id(road)
        , patrol_mode, can_attack))
end

function mt:follow(unit)
    if self:is_destroyed() then
        return
    end
    self._base:api_release_command(GameAPI.create_unit_command_follow(unit._base))
end

function mt:hold(point)
    if self:is_destroyed() then
        return
    end
    if not point then
        point = self:get_point()
    end
    self._base:api_release_command(GameAPI.create_unit_command_hold(point._base))
end

--====EG====--
function mt:empty()
    if self:is_destroyed() then
        return
    end
    self._base:api_release_command(GameAPI.create_unit_command_empty())
end

function mt:get_team()
    return up.actor_team(self._base:api_get_camp())
end

--====EG====--

function mt:stop()
    if self:is_destroyed() then
        return
    end
    self._base:api_release_command(GameAPI.create_unit_command_stop())
end

function mt:attack(target)
    if self:is_destroyed() then
        return
    end
    if target.type == 'point' then
        self._base:api_release_command(GameAPI.create_unit_command_attack_move(target._base))
    elseif target.type == 'unit' then
        if target:is_destroyed() then
            return
        end
        self._base:api_release_command(GameAPI.create_unit_command_attack_target(target._base))
    end
end

function mt:kill(killer)
    if not self:is_destroyed() or not self:is_alive() then
        if not killer then
            self._base:api_kill(nil)
        else
            self._base:api_kill(killer._base)
        end
    end
end

function mt:reborn(point)
    if self:is_destroyed() then
        return
    end
    self._base:api_revive(point._base)
end

function mt:remove()
    if self:is_destroyed() then
        return
    end
    self._base:api_delete()
end

function mt:get_item(type, slot)
    if self:is_destroyed() then
        return nil
    end
    return up.actor_item(self._base:api_get_item_by_slot(SlotType[type], slot))
end

function mt:get_ability(type, id, slot)
    if self:is_destroyed() then
        return nil
    end
    local base
    if id then
        base = self._base:api_get_ability_by_type(abilityType[type], id)
    end
    if slot then
        base = self._base:api_get_ability(abilityType[type], slot)
    end
    if base then
        local data = {}
        for k, v in pairs(up.skill[id]) do
            if data[k] == nil then
                data[k] = v
            end
        end
        local skill = setmetatable(data, mt)
        skill._base = base
        return skill
    else
        return nil
    end
end

function mt:switch_ability(source, target)
    if self:is_destroyed() then
        return
    end
    self._base:api_switch_ability(source._base, target._base)
end

function mt:cast(ability, target)
    if self:is_destroyed() then
        return
    end
    local target_type
    ability = ability._base
    if target then
        target_type = target.type
        target = target._base
    end
    if not target_type then
        self._base:api_release_command(GameAPI.create_unit_command_use_skill(ability))
    elseif target_type == 'point' then
        self._base:api_release_command(GameAPI.create_unit_command_use_skill(ability, target))
    elseif target_type == 'unit' then
        self._base.api_release_command(GameAPI.create_unit_command_use_skill(ability, nil, nil, target))
    elseif target_type == 'item' then
        self._base:api_release_command(GameAPI.create_unit_command_use_skill(ability, nil, nil, nil, target))
    elseif target_type == 'destructable' then
        self._base:api_release_command(GameAPI.create_unit_command_use_skill(ability, nil, nil, nil, nil, target))
    end
end

function mt:cast_pointToPoint(ability, point1, point2)
    if self:is_destroyed() then
        return
    end
    self._base:api_release_command(GameAPI.create_unit_command_use_skill(ability, point1._base, point2._base))
end

--tag
function mt:add_tag(tag)
    if self:is_destroyed() then
        return
    end
    self._base:api_add_tag(tag)
end

function mt:remove_tag(tag)
    if self:is_destroyed() then
        return
    end
    self._base:api_remove_tag(tag)
end

function mt:has_tag(tag)
    if self:is_destroyed() then
        return false
    end
    return self._base:has_tag(tag)
end

--state
function mt:add_restriction(state_name)
    if self:is_destroyed() then
        return
    end
    self._base.api_add_state(RestrictionId[state_name])
end

function mt:remove_restriction(state_name)
    if self:is_destroyed() then
        return
    end
    self._base.api_remove_state(RestrictionId[state_name])
end

function mt:has_restriction(state_name)
    if self:is_destroyed() then
        return false
    end
    return self._base.api_has_state(RestrictionId[state_name])
end

function mt:make_invisible(switch)
    if self:is_destroyed() then
        return
    end
    if switch then
        self._base:api_add_state(512)
    else
        self._base:api_remove_state(512)
    end
    --self._base:api_set_bar_text_visible(not switch)
    --self._base:api_set_hp_bar_visible(not switch)
end

function mt:has_item_type(key)
    if self:is_destroyed() then
        return nil
    end
    return self._base:api_has_item_key(key)
end

function mt:get_level()
    if self:is_destroyed() then
        return nil
    end
    return self._base:api_get_level()
end

function mt:set_level(lv)
    if self:is_destroyed() then
        return
    end
    self._base:api_set_level(lv)
end

function mt:add_level(lv)
    if self:is_destroyed() then
        return
    end
    self._base:api_add_level(lv)
end

function mt:set_exp(exp)
    if self:is_destroyed() then
        return
    end
    self._base:api_set_exp(Fix32(exp))
end

function mt:add_exp(exp)
    if self:is_destroyed() then
        return
    end
    if self:get_player()._base.get_role_type() == 5 then
        self._base:api_add_exp(Fix32(exp * 1))
    elseif self:get_player()._base.get_role_type() == 6 then
        self._base:api_add_exp(Fix32(exp * 1.2))
    else
        self._base:api_add_exp(Fix32(exp))
    end
end

function mt:get_exp()
    if self:is_destroyed() then
        return nil
    end
    return self._base:api_get_exp()
end

function mt:get_up_need_exp()
    if self:is_destroyed() then
        return nil
    end
    return self._base:api_get_upgrade_exp()
end

function mt:blink(point)
    if self:is_destroyed() then
        return
    end
    self._base:api_transmit(point._base)
end

function mt:set_point(point)
    if self:is_destroyed() then
        return
    end
    self._base:api_force_transmit(point._base)
end

function mt:set_time_life(time)
    if self:is_destroyed() then
        return
    end
    self._base:api_set_life_cycle(Fix32(time))
end

function mt:pause_time_life(bool)
    if self:is_destroyed() then
        return
    end
    self._base:api_pause_life_cycle(bool)
end

function mt:get_time_life()
    if self:is_destroyed() then
        return nil
    end
    return self._base:api_get_life_cycle():float()
end

function mt:get_total_time_life()
    if self:is_destroyed() then
        return nil
    end
    return self._base:api_get_total_life_cycle():float()
end

function mt:show_time_bar(time)
    if self:is_destroyed() then
        return
    end
    self._base:api_show_health_bar_count_down(Fix32(time))
end

function mt:damage(data)
    if self:is_destroyed() then
        return
    end
    if not data.target then
        return
    end
    if data.skill then
        data.skill = data.skill._base
    end
    if not data.type then
        data.type = 0
    end

    GameAPI.apply_damage(self._base, data.skill, data.target._base, data.type, Fix32(data.damage), true)
end

function mt:add_damage(data)
    if self:is_destroyed() then
        return
    end
    --ex: u:add_damage{target=u,type = 1,skill = ,damage = }
    local skill
    local type
    local source
    if not data.source then
        source = nil
    else
        source = data.source._base
    end

    if not data.skill then
        skill = nil
    else
        skill = data.skill._base
    end
    if not data.type then
        type = 0
    else
        type = data.type
    end
    if data.jump_word == nil then
        data.jump_word = true
    end
    GameAPI.apply_damage(source, skill, self._base, type, Fix32(data.damage), data.jump_word)
end

-- {
    -- init_time = 0,
    -- end_time = -1,
    -- loop = false,
    -- speed = 1,
    -- name = "attack1",
    -- return_idle = false
-- }
function mt:add_animation(data)
    if self:is_destroyed() then
        return
    end
    if not data.init_time then
        data.init_time = 0
    end
    if not data.end_time then
        data.end_time = -1
    end
    if not data.loop then
        data.loop = false
    end
    if not data.speed then
        data.speed = 1
    end
    self._base:api_play_animation(data.name, data.speed, data.init_time, data.end_time, data.loop,
        data.return_idle or true)
    --self._base:api_play_animation(data.name,data.rate,data.init_time,data.end_time,data.loop)
end

function mt:stop_animation(name)
    if self:is_destroyed() then
        return
    end
    if name then
        self._base:api_stop_animation(name)
    else
        self._base:api_stop_cur_animation()
    end
end

function mt:change_animation(source, target)
    if self:is_destroyed() then
        return
    end
    self._base:api_change_animation(target, source)
end

function mt:cancel_change_animation(source, target)
    if self:is_destroyed() then
        return
    end
    self._base:api_cancel_change_animation(target, source)
end

function mt:clear_change_animation(name)
    if self:is_destroyed() then
        return
    end
    self._base:api_clear_change_animation(name)
end

function mt:ghost_start(data)
    if self:is_destroyed() then
        return
    end
    if not data then
        data = {}
    end
    local r, g, b, a = Fix32(data.r or 255), Fix32(data.g or 255.0), Fix32(data.b or 255.0), Fix32(data.a or 255.0)
    local interval = Fix32(data.interval or 0.3)
    local start = Fix32(data.start or 0.1)
    local dura = Fix32(data.dura or 0.1)
    local over = Fix32(data.over or 0.3)
    self._base.api_start_ghost(r, g, b, a, interval, dura, start, over)
end

function mt:ghost_close()
    if self:is_destroyed() then
        return
    end
    self._base:api_stop_ghost()
end

function mt:ghost_wait_close(time)
    if self:is_destroyed() then
        return
    end
    local unit = self
    if unit.ghost_wait_close_timer then
        unit.ghost_wait_close_timer:remove()
    end
    unit.ghost_wait_close_timer = up.wait(time, function()
        unit:ghost_close()
        unit.ghost_wait_close_timer:remove()
        unit.ghost_wait_close_timer = nil
    end)
end

function mt:ghost_set_color(r, g, b, a)
    if self:is_destroyed() then
        return
    end
    self._base:api_set_ghost_color(Fix32(r), Fix32(g), Fix32(b), Fix32(a))
end

function mt:ghost_set_time(interval, start, dura, over)
    if self:is_destroyed() then
        return
    end
    self._base:api_set_ghost_time(Fix32(interval), Fix32(start), Fix32(dura), Fix32(over))
end

function mt:change_model(name)
    if self:is_destroyed() then
        return
    end
    self._base:api_replace_model(name)
end

function mt:cancel_change_model(name)
    if self:is_destroyed() then
        return
    end
    self._base:api_cancel_replace_model(name)
end

function mt:get_pkg_size()
    return self._base:api_get_unit_pkg_cnt()
end

function mt:get_bag_size()
    if self:is_destroyed() then
        return nil
    end
    return self._base:api_get_unit_pkg_cnt()
end

function mt:get_model()
    if self:is_destroyed() then
        return nil
    end
    return self._base:api_get_model()
end

function mt:set_hp_bar_type(i)
    if self:is_destroyed() then
        return
    end
    self._base.api_set_blood_bar_show_type(HeadBarShowType[i])
end

function mt:set_scale(scale)
    if self:is_destroyed() then
        return
    end
    self._base:api_set_scale(scale)
end

function mt:get_height()
    if self:is_destroyed() then
        return 0
    end
    return self._base:api_get_height():float()
end

function mt:set_height(height, speed)
    if self:is_destroyed() then
        return
    end
    if speed then
        self._base:api_raise_height(Fix32(height), Fix32(speed))
    else
        self._base:api_raise_height(Fix32(height), Fix32(0.0))
    end
end

function mt:add_height(height, speed)
    if self:is_destroyed() then
        return
    end
    height = self:get_height() + height
    if speed then
        self._base:api_raise_height(Fix32(height), Fix32(speed))
    else
        self._base:api_raise_height(Fix32(height), Fix32(0.0))
    end
end

function mt:get_facing()
    if self:is_destroyed() then
        return 0
    end
    return self._base:get_face_angle():float()
end

function mt:set_facing(angle, time)
    if self:is_destroyed() then
        return
    end
    local b = true
    if not time then
        time = 0
    end
    if time == 0 then
        b = false
    end
    if b then
        self._base:api_set_face_angle(Fix32(angle), Fix32(time * 1000))
    else
        self._base:api_set_face_angle(Fix32(angle), Fix32(-1))
    end
end

function mt:set_facing_point(point, time)
    if self:is_destroyed() then
        return
    end
    local b = true
    if not time then
        time = 0
    end
    if time == 0 then
        b = false
    end
    if b then
        self._base:api_set_face_angle(GameAPI.get_points_angle(self._base:api_get_position(), point._base),
            Fix32(time * 1000))
    else
        self._base:api_set_face_angle(Fix32(angle), Fix32(-1))
    end
end

function mt:get_turn_speed()
    if self:is_destroyed() then
        return nil
    end
    return self._base:api_get_turn_speed()
end

function mt:set_turn_speed(speed)
    if self:is_destroyed() then
        return
    end
    self._base:set_turn_speed(Fix32(speed))
end

function mt:is_alive()
    if self:is_destroyed() then
        return false
    end
    return self._base:api_is_alive()
end

function mt:is_dead()
    if self:is_destroyed() then
        return true
    end
    return self:is_alive() == false
end

function mt:is_move()
    if self:is_destroyed() then
        return false
    end
    return self._base:api_is_moving()
end

function mt:has_item(item)
    if self:is_destroyed() then
        return false
    end
    return self._base:api_has_item(item)
end

function mt:is_shop()
    if self:is_destroyed() then
        return nil
    end
    return self._base:api_is_shop()
end

function mt:add_shop_item(tab, item)
    if self:is_destroyed() then
        return
    end
    self._base:api_add_shop_item(tab, item._base)
end

function mt:add_shop_unit(tab, unit)
    if self:is_destroyed() then
        return
    end
    self._base:api_add_shop_unit(tab, unit._base)
end

function mt:remove_shop_item(tab, id)
    if self:is_destroyed() then
        return
    end
    self._base:api_remove_shop_item(tab, id)
end

function mt:remove_shop_unit(tab, id)
    if self:is_destroyed() then
        return
    end
    self._base:api_remove_shop_unit(tab, id)
end

function mt:set_shop_item_stock(tab, id, cnt)
    if self:is_destroyed() then
        return
    end
    self._base:set_shop_item_stock(tab, id, cnt)
end

function mt:set_shop_unit_stock(tab, id, cnt)
    if self:is_destroyed() then
        return
    end
    self._base:api_set_shop_unit_stock(tab, id, cnt)
end

function mt:buy_item(shop, tab, id)
    if self:is_destroyed() then
        return
    end
    if not shop:is_shop() then
        return
    end
    self._base:api_buy_item_with_tab_name(shop._base, tab, id)
end

function mt:buy_unit(shop, tab, id)
    if self:is_destroyed() then
        return
    end
    if not shop:is_shop() then
        return
    end
    self._base:api_buy_unit_with_tab_name(shop._base, tab, id)
end

function mt:sell_item(shop, item)
    if self:is_destroyed() then
        return
    end
    self._base:api_sell_item(shop._base, item._base)
end

function mt:get_shop_item_stock(tab, id)
    if self:is_destroyed() then
        return 0
    end
    return self._base:api_get_shop_item_stock(tab, id)
end

function mt:get_shop_unit_stock(tab, id)
    if self:is_destroyed() then
        return 0
    end
    return self._base:api_get_shop_unit_stock(tab, id)
end

function mt:get_shop_tab_cnt()
    if self:is_destroyed() then
        return 0
    end
    return self._base:api_get_shop_tab_cnt()
end

function mt:get_shop_range()
    if self:is_destroyed() then
        return 0
    end
    return self._base:api_get_shop_range():float()
end

function mt:get_shop_tab_name(tab_idx)
    if self:is_destroyed() then
        return nil
    end
    return self._base:api_get_shop_tab_name(tab_idx)
end

function mt:get_tab_good_cnt(tab_idx)
    if self:is_destroyed() then
        return 0
    end
    local a = self._base:api_get_shop_item_list(tab_idx)
    local n = 0
    for index, value in Python.enumerate(a) do
        n = n + 1
    end
    return n
end

function up.unit_class.__index:each_goods(tab_idx)
    if self:is_destroyed() then
        return nil
    end
    local a = self._base:api_get_shop_item_list(tab_idx)
    local goods_list = {}
    for _, key in Python.enumerate(a) do
        table.insert(goods_list, key)
    end
    local n = 0
    return function(t, v)
        n = n + 1
        return t[n]
    end, goods_list
end

function mt:get_shop_tab_goods_key(tab_idx, id)
    if self:is_destroyed() then
        return nil
    end
    local a = self._base:api_get_shop_item_list(tab_idx)
    for index, value in Python.enumerate(a) do
        if index == id - 1 then
            return value
        end
    end
end

function mt:get_shop_item_cd(tab_idx, key)
    if self:is_destroyed() then
        return 0
    end
    local t = self._base:api_get_shop_item_cd(tab_idx, key)
    if t then
        local cd = {}
        for _, value in Python.enumerate(t) do
            table.insert(cd, value:float())
        end
        return cd
    else
        return nil
    end
end

function mt:create_unit(name, point, angle)
    local u = up.create_unit(name, point, angle, self:get_player())
    return u
end

local up_event_dispatch = up.event_dispatch
local up_event_notify = up.event_notify
local up_game = up.game


function mt:event(name, f)
    if self:is_destroyed() then
        return
    end
    return up.event_register(self, name, f)
end

function mt:event_dispatch(name, ...)
    if self:is_destroyed() then
        return
    end
    local res, arg = up_event_dispatch(self, name, ...)
    if res ~= nil then
        return res, arg
    end
    local player = self:get_owner()
    if player then
        local res, arg = up_event_dispatch(player, name, ...)
        if res ~= nil then
            return res, arg
        end
    end
    local res, arg = up_event_dispatch(up_game, name, ...)
    if res ~= nil then
        return res, arg
    end
    return nil
end

function mt:event_notify(name, ...)
    if self:is_destroyed() then
        return
    end
    up_event_notify(self, name, ...)
    local player = self:get_owner()
    if player then
        up_event_notify(player, name, ...)
    end
    up_event_notify(up_game, name, ...)
end

function mt:is_enemy(dest)
    if self:is_destroyed() then
        return nil
    end
    return GameAPI.is_enemy(self._base, dest._base)
end

function mt:is_ally(dest)
    if self:is_destroyed() then
        return nil
    end
    return GameAPI.is_ally(self._base, dest._base)
end

function mt:is_hero()
    if self:is_destroyed() then
        return nil
    end
    return self:get_type() == 'hero'
end

function mt:get_atk_type()
    if self:is_destroyed() then
        return nil
    end
    return self._base:api_get_atk_type()
end

function mt:get_def_type()
    if self:is_destroyed() then
        return nil
    end
    return self._base:api_get_def_type()
end

function mt:get_main_attr()
    if self:is_destroyed() then
        return nil
    end
    return self._base:api_get_main_attr()
end

function mt:get_select_circle_scale()
    if self:is_destroyed() then
        return nil
    end
    return GameAPI.get_select_circle_scale(self._base):float()
end

function mt:is_building()
    if self:is_destroyed() then
        return nil
    end
    return self:get_type() == 'building'
end

function mt:is_type(flag)
    if self:is_destroyed() then
        return nil
    end
    return self:get_type() == flag
end

function mt:is_illusion()
    if self:is_destroyed() then
        return nil
    end
    return GameAPI.is_unit_illusion(self._base)
end

function mt:is_destroyed()
    if self then
        return self._base.api_is_destroyed()
    end
end

function mt:is_visible(dest)
    if self:is_destroyed() then
        return false
    end
    return GameAPI.get_visibility_of_unit(self._base, dest._base)
end

function mt:can_blink(point)
    if self:is_destroyed() then
        return false
    end
    return self._base.api_can_teleport_to(point._base)
end

function mt:can_attack()
    return true
end

function mt:get(attr, type)
    if self:is_destroyed() then
        return nil
    end
    if attrType[attr] then
        attr = attrType[attr]
    end
    if not type then
        return self._base:api_get_float_attr(attr):float()
    end
    local type_list = {
        ['Base'] = function()
            return self._base:api_get_attr_base(attr):float()
        end,
        ['BaseRatio'] = function()
            return self._base:api_get_attr_base_ratio(attr):float()
        end,
        ['Bonus'] = function()
            return self._base:api_get_attr_bonus(attr):float()
        end,
        ['BonusRatio'] = function()
            return self._base:api_get_attr_bonus_ratio(attr):float()
        end,
        ['AllRatio'] = function()
            return self._base:api_get_attr_all_ratio(attr):float()
        end,
        ['Extra'] = function()
            return self._base:api_get_attr_other(attr):float()
        end,
    }
    return type_list[type]()
end

function mt:set(attr, value, type)
    if self:is_destroyed() then
        return
    end
    if not type then
        type = 'Base'
    end
    if attrType[attr] then
        attr = attrType[attr]
    end
    if attr == 'hp_cur' or attr == 'mp_cur' then
        self._base:api_set_attr(attr, Fix32(value))
        return
    end
    local type_list = {
        ['Base'] = function()
            self._base:api_set_attr_base(attr, Fix32(value))
        end,
        ['BaseRatio'] = function()
            self._base:api_set_attr_base_ratio(attr, Fix32(value))
        end,
        ['Bonus'] = function()
            self._base:api_set_attr_bonus(attr, Fix32(value))
        end,
        ['BonusRatio'] = function()
            self._base:api_set_attr_bonus_ratio(attr, Fix32(value))
        end,
        ['AllRatio'] = function()
            self._base:api_set_attr_all_ratio(attr, Fix32(value))
        end,
    }
    type_list[type]()
end

function mt:add(attr, value, type)
    if self:is_destroyed() then
        return
    end
    if attrType[attr] then
        attr = attrType[attr]
    end
    -- self._base:api_add_attr_base(attr, Fix32(value))
    if not type then
        type = 'Base'
    end
    local type_list = {
        ['Base'] = function()
            self._base:api_add_attr_base(attr, Fix32(value))
        end,
        ['BaseRatio'] = function()
            self._base:api_add_attr_base_ratio(attr, Fix32(value))
        end,
        ['Bonus'] = function()
            self._base:api_add_attr_bonus(attr, Fix32(value))
        end,
        ['BonusRatio'] = function()
            self._base:api_add_attr_bonus_ratio(attr, Fix32(value))
        end,
        ['AllRatio'] = function()
            self._base:api_add_attr_all_ratio(attr, Fix32(value))
        end,
    }
    type_list[type]()
end

--kv
function mt:setKv(key, value)
    if self:is_destroyed() then
        return
    end
    GameAPI.add_float_kv(self:get_key(), key, value)
end

--todo
function mt:getKv(key, type, isType)
    if self:is_destroyed() then
        return
    end
end

function mt:hasTypeKv(key, type)
    if self:is_destroyed() then
        return false
    end
    return GameAPI['has_unit_key_' .. KvType[type] .. '_kv'](self:get_key(), key)
end

function mt:getTypeKv(key, type)
    if self:is_destroyed() then
        return nil
    end
    local value = GameAPI['get_unit_key_' .. KvType[type] .. '_kv'](self:get_key(), key)
    if type == 'real' then
        value = value:float()
    end
    if type == 'int' then
        value = value:int()
    end
    return value
end

local Units = {}
function up.actor_unit(u)
    if u == nil then
        return nil
    end
    local id
    if type(u) == 'number' then
        id = u
        u = GameAPI.get_unit_by_id(u)
    else
        id = u:api_get_id()
    end
    if not Units[id] then
        local unit = {}
        unit._base = u
        setmetatable(unit, mt)
        Units[id] = unit
    end
    return Units[id]
end

up.game:event('Unit-Delete', function(_, unit, _id)
    if not _id then
        return
    end
    Units[_id] = nil
end)


function up.create_unit(name, point, angle, player)
    local u = GameAPI.create_unit(name, point._base, Fix32(angle), player._base)
    return up.actor_unit(u)
end
