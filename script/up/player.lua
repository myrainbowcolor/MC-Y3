local math = math
local table = table
local setmetatable = setmetatable
local type = type

--- @class Player
--- @field hitCube Cube
local mt = {}
mt.__index = mt

mt.type = 'player'


local Player = {}

function mt:__tostring()
    return ('%s|%s|%s'):format('player', self:get_name(), tostring(self._base))
end

function mt:set_input(bool)
    GameAPI.block_global_mouse_event(self._base, bool)
    --GameAPI.block_global_key_event(self._base,bool)
end

function mt:refresh_team_list(team_id)
    local u = GameAPI.get_unit_ids_in_team(self._base, team_id)
    self._base:role_select_unit(u)
end

function mt:get_team_unit(team_id)
    local u = GameAPI.get_unit_ids_in_team(self._base, team_id)
    local group = {}
    for index, value in Python.enumerate(u) do
        local a = up.actor_unit(value)
        table.insert(group, a)
    end
    return group
end

function mt:add(key, value)
    self._base:change_role_res(key, Fix32(value))
end

function mt:set(key, value)
    self._base:set_role_res(key, Fix32(value))
end

function mt:get(key)
    return self._base:get_role_res(key):float()
end

function mt:get_status()
    return RoleStatus[self._base:get_role_status()]
end

function mt:get_name()
    return self._base:get_role_name()
end

function mt:set_name(name)
    self._base:set_role_name(name)
end

function mt:get_type()
    return RoleType[self._base:get_role_type()]
end

function mt:get_mouse_pos()
    return up.actor_point(GameAPI.get_player_pointing_pos(self._base))
end

function mt:set_mouse_select(flag)
    self._base.set_role_mouse_move_select(flag)
end

function mt:set_mouse_click(flag)
    self._base.set_role_mouse_left_click(flag)
end

function mt:get_id()
    return self._base:get_role_id_num()
end

function mt:set_exp_rate(rate)
    self._base:set_role_exp_rate(rate)
end

function mt:get_exp_rate()
    return self._base:get_role_exp_rate()
end

function mt:show_text(text)
    --GameAPI.show_msg_to_role(self._base,text,false)
end

function mt:msg(text)
    GameAPI.show_msg_to_role(self._base, text, false)
end

--Technology related
function mt:set_tech_lv(tech, lv)
    self._base:api_set_tech_level(tech, lv)
end

function mt:get_tech_lv(tech)
    return self._base:api_get_tech_level(tech)
end

function mt:get_tech_level(tech)
    return self._base:api_get_tech_level(tech)
end

function mt:add_tech_level(tech, lv)
    return self._base:api_change_tech_level(tech, lv)
end

function mt:set_tech_level(tech, lv)
    return self._base:api_set_tech_level(tech, lv)
end

function mt:get_team()
    return up.team(self._base:api_get_camp_id())
end

function mt:set_team(id)
    self._base:set_role_camp_id(id)
end

function mt:create_unit(name, point, angle)
    return up.create_unit(name, point, angle, self, owner)
end

function mt:select(unit, flag)
    if not unit then return end
    if flag then
        self._base:role_select_unit(unit._base)
    else
        up.wait(0.033, function()
            self._base:role_select_unit(unit._base)
        end)
    end
end

function mt:set_born_point(point)
    self._base:set_role_spawn_point(point._base)
end

function mt:get_born_point()
    return up.actor_point(self._base:get_role_spawn_point())
end

function mt:set_alliance_state(role, state)
    self._base:set_role_hostility(role._base, state)
end

function mt:game_win()
    GameAPI.set_melee_result_by_role(self._base, 'victory', true, false, 0, false)
end

function mt:game_bad()
    GameAPI.set_melee_result_by_role(self._base, 'defeat', true, false, 0, false)
end

function mt:camera_focus(unit)
    GameAPI.camera_set_follow_unit(self._base, unit._base)
end

function mt:camera_unfocus()
    GameAPI.camera_cancel_follow_unit(self._base)
end

function mt:get_units_by_key(key)
    local group = {}
    local u = GameAPI.get_units_by_key(key)
    for index, value in Python.enumerate(u) do
        local a = up.actor_unit(value)
        if a then
            if a:get_owner() == self then
                table.insert(group, a)
            end
        end
    end
    return group
end

function mt:remove_team_unit(team_id, unit)
    GameAPI.remove_unit_from_team(self._base, team_id, unit._base)
end

function mt:use_camera(data)
    local h = GameAPI.get_point_ground_height(up.point(data.x, data.y)):float()
    local c = GameAPI.add_camera_conf(Fix32Vec3(data.x / 100, 0, data.y / 100), data.dis / 100, (data.height / 100),
        data.yaw - 90, 360 - data.pitch, data.fov)

    GameAPI.apply_camera_conf(self._base, c, data.time)
end

function mt:set_camera(point)
    GameAPI.camera_linear_move_duration(self._base, Fix32Vec3(point.x / 100, 0, point.y / 100), Fix32(0.1), Fix32(0))
end

function mt:set_camera_distance(dis)
    GameAPI.camera_set_param_distance(self._base, dis / 100)
end

function mt:camera_shake_z(dis, speed, time)
end

function mt:camera_shake(dis, speed, time, angle)
    if angle == 'z' then
        GameAPI.camera_shake_z(self._base, Fix32(dis), Fix32(speed), Fix32(time))
    elseif angle == 'x' then
        GameAPI.camera_shake_xy(self._base, Fix32(dis), Fix32(speed), Fix32(time), 1)
    else
        GameAPI.camera_shake_xy(self._base, Fix32(dis), Fix32(speed), Fix32(time), 2)
    end
end

function mt:set_camera_pitch(pitch, time)
    if time then
        GameAPI.camera_rotate_pitch_angle_duration(self._base, pitch, time)
    else
        GameAPI.camera_set_param_pitch(self._base, pitch)
    end
end

function mt:set_camera_yaw(yaw, time)
    if time then

        GameAPI.camera_rotate_yaw_angle_duration(self._base, yaw, time)
    else
        GameAPI.camera_set_param_yaw(self._base, yaw)
    end

end

function mt:remove_control_unit(unit)
    GameAPI.remove_control_unit(self._base, unit._base)
end

function mt:camera_set_focus_y(y)
    GameAPI.camera_set_focus_y(self._base, y)
end

--Conditional judgment

function mt:is_ally(role)
    return self._base:players_is_alliance(role._base)
end

function mt:is_enemy(role)
    return self._base:players_is_enemy(role._base)
end

function mt:is_pressed(key)
    return GameAPI.player_key_is_pressed(self._base, key)
end

function mt:is_key_pressed(key)
    return GameAPI.player_key_is_pressed(self._base, KEY[key])
end

function mt:check_tech_precondition(key)
    if self.tech_percondition_cache[key] == nil then
        return gameapi.check_tech_key_precondition(self._base, key)
    else
        return self.tech_percondition_cache[key]
    end
end

function mt:check_unit_precondition(key)
    return gameapi.check_unit_key_precondition(self._base, key)
end

function mt:check_ability_precondition(key)
    return gameapi.check_ability_key_precondition(self._base, key)
end

function mt:check_item_precondition(key)
    if self.item_percondition_cache[key] == nil then
        return gameapi.check_item_key_precondition(self._base, key)
    else
        return self.item_percondition_cache[key]
    end
end

function mt:is_playing()
    return self:get_status() == "playing"
end

function mt:is_user()
    return self:get_type() == 'user'
end

function mt:is_ai()
    return self:get_type() == 'ai'
end

local up_event_dispatch = up.event_dispatch
local up_event_notify = up.event_notify
local up_game = up.game

--register Event
function mt:event(name, f)
    return up.event_register(self, name, f)
end

--fire Event
function mt:event_dispatch(name, ...)
    local res, arg = up_event_dispatch(self, name, ...)
    if res ~= nil then
        return res, arg
    end
    local res, arg = up_event_dispatch(up_game, name, ...)
    if res ~= nil then
        return res, arg
    end
    return nil
end

function mt:event_notify(name, ...)
    up_event_notify(self, name, ...)
    up_event_notify(up_game, name, ...)
end

function up.player(i)
    if not Player[i] then
        local player = {}
        player._base = GameAPI.get_role_by_int(i)
        if not player._base then return nil end
        setmetatable(player, mt)
        Player[i] = player
        Player[i].item_percondition_cache = {}
        Player[i].tech_percondition_cache = {}
    end
    return Player[i]
end

-- 设置玩家表格类型数据存档
--- @param id integer 定义改存档时候的顺序id
--- @param tb table 数据表
function mt:set_save_data_table_value(id, tb)
    self._base:set_save_data_table_value(id, tb)
end

-- 获取玩家表格类型数据存档
--- @param id integer 定义改存档时候的顺序id
--- @return table
function mt:get_save_data_table_value(id)
    return self._base:get_save_data_table_value(id)
end

--- @class Sound

-- 播放声音
--- @param data table
--- @return Sound
function mt:play_sound(data)
    -- {
    --     key = 10001,
    --     fadeIn = 0,
    --     fadeOut = 0,
    --     cycle = false
    -- }
    return GameAPI.play_sound_for_player(self._base, data.key, data.cycle, data.fadeIn, data.fadeOut)
end

-- 播放3D声音
--- @param data table
--- @return Sound
function mt:play_3d_sound(data)
    -- {
    --     key = 10001,
    --     point = up.point(0, 0, 0),
    --     height = 0,
    --     fadeIn = 0,
    --     fadeOut = 0,
    --     cycle = false,
    --     insure = true
    -- }
    data.fadeIn = data.fadeIn or 0
    data.fadeOut = data.fadeOut or 0
    if not data.cycle then
        data.cycle = false
    end
    if not data.insure then
        data.insure = true
    end
    return GameAPI.play_3d_sound_for_player(self._base, data.key, data.point._base, Fix32(data.height), data.fadeIn,
        data.fadeOut, data.insure, data.cycle)
end

-- 跟随单位播放3D声音
--- @param data table
--- @param unit Actor
--- @return Sound
function mt:play_3d_sound_follow_unit(data, unit)
    -- {
    --     key = 10001,
    --     point = up.point(0, 0, 0),
    --     height = 0,
    --     fadeIn = 0,
    --     fadeOut = 0,
    --     cycle = false,
    --     insure = true
    -- }
    data.fadeIn = data.fadeIn or 0
    data.fadeOut = data.fadeOut or 0
    if not data.cycle then
        data.cycle = false
    end
    if not data.insure then
        data.insure = true
    end
    return GameAPI.follow_object_play_3d_sound_for_player(self._base, data.key, unit._base, data.fadeIn, data.fadeOut,
        data.insure, data.cycle)
end

-- 停止播放声音
--- @param sound Sound
--- @param isOnceStop boolean
function mt:stop_sound(sound, isOnceStop)
    GameAPI.stop_sound(Player._base, sound, isOnceStop or false)
end
