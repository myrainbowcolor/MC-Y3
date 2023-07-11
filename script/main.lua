--py
require 'python'
Python = python
GameAPI = gameapi
GlobalAPI = globalapi
Fix32Vec3 = Fix32Vec3
Fix32 = Fix32
New_global_trigger = new_global_trigger
New_modifier_trigger = new_modifier_trigger
New_item_trigger = new_item_trigger
-- constant --
PLAYER_CAMP_ID = 1
NEUTRAL_ENEMY_CAMP_ID = 31
NEUTRAL_FRIEND_CAMP_ID = 32
Python = python
New_global_trigger = new_global_trigger
New_modifier_trigger = new_modifier_trigger
New_item_trigger = new_item_trigger

SUMMON_UNITS = {}
MAX_SUMMON_NUM = 5
PLAYER_MAX = 1
ALL_PLAYER = GameAPI.get_all_role_ids()
UI_EVENT_LIST = {
	'CameraToUnit',
	'task1',
	'task2',
	'focus_btn_click',
	'defocus_btn_click',
	'close_shop',
	'shop_tab_up',
	'shop_tab_down',
	'back_game',
}


for i = 1, 6 do
	table.insert(UI_EVENT_LIST, 'ClickHero_' .. i)
	table.insert(UI_EVENT_LIST, 'show_item_tips_' .. i)
end

for i = 1, 10 do
	table.insert(UI_EVENT_LIST, 'skill_tips_show_' .. i)
end

for i = 1, 32 do
	table.insert(UI_EVENT_LIST, 'TouchStart_' .. i)
end

for i = 1, 36 do
	table.insert(UI_EVENT_LIST, 'in_bagItem_' .. i)
end
for i = 1, 4 do
	table.insert(UI_EVENT_LIST, 'shop_tab_' .. i)
end

for i = 1, 6 do
	table.insert(UI_EVENT_LIST, 'sell_item_show_' .. i)
end

for i = 1, 6 do
	table.insert(UI_EVENT_LIST, 'tech_click_' .. i)
	table.insert(UI_EVENT_LIST, 'techtips_show_' .. i)
	table.insert(UI_EVENT_LIST, 'techtips_hide_' .. i)
end

--buff
for i = 1, 10 do
	table.insert(UI_EVENT_LIST, 'bufftips_show_' .. i)
	table.insert(UI_EVENT_LIST, 'bufftips_hide_' .. i)
end

for i = 1, 36 do
	table.insert(UI_EVENT_LIST, 'TouchRightClick_' .. i)
end
for i = 2, 53 do
	table.insert(UI_EVENT_LIST, 'MouseEnter_' .. i)
	table.insert(UI_EVENT_LIST, 'MouseLeave_' .. i)
end

for i = 1, 50 do
	table.insert(UI_EVENT_LIST, 'None_' .. i)
end

require 'up'
--require 'test.test'
---resource block start---
---The resource usage statement should be at the beginning of the script and the comments at the beginning and end of this section cannot be modified!!!  xxx_id refer to maps/offical_expr_data/trigger_related_xxx.json

local setmetatable = setmetatable

--up.player:msg('lua','init success')

-- up.game:event('Game-Init', function(_, data)
--     up.player:msg('test','init success')

-- end)

-- require 'ui'
-- require 'game'
-- require 'random_trigger'
-- require 'ltyj'
-- require 'global_protect'

-- ====================================-EG-================================ --
require("Util")
require("MC")

do
	--- @type table<integer, Cube>
	local campOneBlackCubeArr = {} -- 阵营1的床块数组
	--- @type table<integer, Cube>
	local campTwoBlackCubeArr = {} -- 阵营2的床块数组
	--[[
		函数
	--]]

	-- 获取摄像机朝向
	local function getCameraDirection(player)
		local cameraDirection = gameapi.get_player_camera_direction(player._base)
		local cameraDirectionTemp = up.actor_point(cameraDirection)
		return Util:creatVector(cameraDirectionTemp:get_x(), cameraDirectionTemp:get_y(), cameraDirectionTemp:get_z())
	end

	-- 创建摄像机到鼠标世界坐标的射线
	local function creatRayCameraToMouseWorldPoint(cameraPoint, player)
		local mousePoint = getMouseWorldPoint(player)
		local vector = Util:creatVector(
			mousePoint.x - cameraPoint.x,
			mousePoint.y - cameraPoint.y,
			mousePoint.z - cameraPoint.z
		)
		return Util:creatRay(cameraPoint, vector)
	end

	-- 是否存在浮点数键值对
	local function isExitFloatKv(obj, key)
		return GameAPI.has_kv_pair_float(obj._base, key)
	end

	-- 获取玩家绑定单位的id
	local function getPlayerBindUnitId(player, key)
		return GameAPI.get_kv_pair_value_unit_entity(player._base, key):api_get_id()
	end

	-- 获取玩家绑定浮点数值
	local function getPlayerBindFloat(player, key)
		return GameAPI.get_kv_pair_value_float(player._base, key):float()
	end

	-- 获取玩家绑定字符串值
	local function getPlayerBindString(player, key)
		return GameAPI.get_kv_pair_value_string(player._base, key)
	end

	-- 玩家是否存在字符串自定义值
	local function isPlayerExitStringKv(player, key)
		return GameAPI.has_kv_pair_string(player._base, key)
	end

	-- 玩家是否存在整数自定义值
	local function isExitIntegerKv(player, key)
		return GameAPI.has_kv_pair_integer(player._base, key)
	end

	-- 获取玩家当前使用物品的槽位id
	local function getPlayerCurUseItemSlotId(player, key)
		return GameAPI.get_kv_pair_value_integer(player._base, key)
	end

	-- 获取单位绑定浮点数值
	local function getUnitBindFloat(unit, key)
		return GameAPI.get_kv_pair_value_float(unit.actor._base, key):float()
	end

	-- 获取单位绑定玩家
	local function getUnitBindPlayer(unit, key)
		return up.player(GameAPI.get_kv_pair_value_player(unit.actor._base, key):get_role_id_num())
	end

	-- 获取鼠标世界坐标
	local function getMouseWorldPoint(player)
		local mousePointTemp = up.actor_point(GameAPI.get_player_pointing_pos(player._base))
		return Util:creatVector(mousePointTemp:get_x(), mousePointTemp:get_y(), mousePointTemp:get_z())
	end

	-- 计算摄像机位置
	--- @param unit Unit
	--- @param cameraDistance number|nil
	local function caculatCameraPoint(player, unit, cameraDistance)
		local unitTopPoint = Unit:getUnitTopPoint(unit)
		local cameraDirection = getCameraDirection(player)
		return Util:creatVector(
			unitTopPoint.x - cameraDirection.x * ((cameraDistance or 0) / 100),
			unitTopPoint.y - cameraDirection.y * ((cameraDistance or 0) / 100),
			unitTopPoint.z - cameraDirection.z * ((cameraDistance or 0) / 100)
		)
	end

	-- 计算重力作用下单位的当前世界高度(底部高度)
	--- @param unit  Unit
	--- @param time number
	--- @return number
	local function caculatCurUnitWorldHeightByGravity(unit, time)
		local unitWorldHeight = unit.jumpInitHeight
		local h = unit.vg * time - 1 / 2 * g * (time ^ 2)
		--[[
			h = vg * t - 1 / 2 * g * (t ^ 2)
		--]]
		unit.curVg = unit.vg - time * g
		return unitWorldHeight + h
	end

	-- 获取自由落体高度下的下落速度
	local function getHToSVg(h)
		return math.sqrt(2 * h / g) * g
	end

	-- 创建连接特效(测试用)
	local function creatLinkEffect(key, orig, dest)
		local data = {
			id = key,
			source = up.point(orig.x, orig.y, orig.z),
			target = up.point(dest.x, dest.y, dest.z),
			source_height = orig.z,
			target_height = dest.z,
		}
		return up.lightning(data)
	end

	-- 获取点水平偏移后的点
	local function getPointHorizontalOffsetPoint(point, angle, distance)
		local offsetPointTemp = up.point(point.x, point.y, 0):offset(angle % 360, distance * 100)
		local offsetPoint = Util:creatVector(
			offsetPointTemp:get_x() / 100,
			offsetPointTemp:get_y() / 100,
			point.z
		)
		return offsetPoint
	end

	-- 获取单位移动方向
	local function getUnitMoveDirection(player, unit)
		local direction = nil
		local x = 0
		local y = 0
		local isPressW = player:is_key_pressed("W")
		local isPressS = player:is_key_pressed("S")
		local isPressA = player:is_key_pressed("A")
		local isPressD = player:is_key_pressed("D")
		if isPressW then
			y = y + 1
		end
		if isPressS then
			y = y - 1
		end
		if isPressA then
			x = x + 1
		end
		if isPressD then
			x = x - 1
		end
		local unitFacing = unit.actor:get_facing()
		if x == 1 and y == 0 then
			return unitFacing + 90
		end
		if x == -1 and y == 0 then
			return unitFacing - 90
		end
		if x == 0 and y == 1 then
			return unitFacing
		end
		if x == 0 and y == -1 then
			return unitFacing - 180
		end
		if x == 1 and y == 1 then
			return unitFacing + 45
		end
		if x == -1 and y == -1 then
			return unitFacing - 135
		end
		if x == 1 and y == -1 then
			return unitFacing + 135
		end
		if x == -1 and y == 1 then
			return unitFacing - 45
		end
		if x == 0 and y == 0 then
			return unitFacing
		end
	end

	-- 单位停止移动
	local function unitStopMove(unit)
		unit.actor:empty() -- 打断其余移动命令
		unit.actor:set("ori_speed", 0)
		-- !! 还差一个增益速度为0
	end

	-- 单位添加布尔自定义值
	local function unitAddUerDefineBoolenKv(unit, key, value)
		GameAPI.add_boolean_kv(unit.actor._base, key, value)
	end

	-- 获取单位绑定布尔值
	local function getUnitBindBoolean(unit, key)
		return GameAPI.get_kv_pair_value_boolean(unit._base, key)
	end

	-- 单位是否存在布尔自定义值
	local function isUnitExitBooleanKv(unit, key)
		return GameAPI.has_kv_pair_boolean(unit._base, key)
	end

	-- 玩家添加可破坏物自定义值
	local function playerAddUerDefineDestructableKv(player, key, value)
		GameAPI.add_destructible_entity_kv(player._base, key, value)
	end

	-- 玩家添加浮点数自定义值
	local function playerAddUerDefineFloatKv(player, key, value)
		GameAPI.add_float_kv(player._base, key, value)
	end

	-- 区域添加浮点数自定义值
	local function areaAddUerDefineFloatKv(area, key, value)
		GameAPI.add_float_kv(area._base, key, value)
	end

	-- 玩家添加表自定义值
	local function playerAddUerDefineTableKv(player, key, value)
		GameAPI.add_table_kv(player._base, key, value)
	end

	-- 玩家添加字符串自定义值
	local function playerAddUerDefineStringKv(player, key, value)
		GameAPI.add_string_kv(player._base, key, value)
	end

	-- 获取玩家绑定的可破坏物
	local function getPlayerBindDestructable(player, key)
		return GameAPI.get_kv_pair_value_destructible_entity(player._base, key)
	end

	-- 重置单位碰撞类型
	local function resetUnitCollisionType(unit)
		for k, v in pairs(unit.collisionType) do
			unit.collisionType[k] = false
			unitAddUerDefineBoolenKv(unit, k, v)
		end
	end

	-- 转换Vector类型为string类型
	--- @param cube Cube
	--- @return string "x|y|z|type|campId"
	local function vectorToString(cube)
		local point = cube.cubeModel.centerPoint
		local type = string.sub(cube.type, #"type:" + 1)
		local campId = nil
		local str = nil
		if cube.camp then
			campId = cube.camp:get_id()
			str = tostring(point.x) .. "|" .. tostring(point.y) .. "|" .. tostring(point.z) .. "|" .. type .. "|" .. campId
		else
			str = tostring(point.x) .. "|" .. tostring(point.y) .. "|" .. tostring(point.z) .. "|" .. type
		end
		return str
	end

	-- 选中特效
	local function chooseParticle(unitArr)
		local hitCubeArr = {}
		for _, unit in pairs(unitArr) do
			local player = getUnitBindPlayer(unit, "PLAYER")
			local key = "navigationTemp"
			local angle = isExitFloatKv(player, key) and getPlayerBindFloat(player, key) or unit.actor:get_facing()
			local originPoint = getPointHorizontalOffsetPoint(caculatCameraPoint(player, unit), angle, 150)
			local cameraDirection = getCameraDirection(player)
			local ray = Util:creatRay(originPoint, cameraDirection)
			local hitCube, _, hitcubePlaneName = Cube:getRayHitCubeInfo(ray, unit.height * 2.5)
			if hitCube then
				local chooseItemId = -1
				if isExitIntegerKv(player, "chooseItemId") then
					chooseItemId = getPlayerCurUseItemSlotId(player, "chooseItemId")
				end
				if chooseItemId ~= 1 and chooseItemId ~= 4 then
					table.insert(hitCubeArr, hitCube) -- 加入显示选中数组
				end
				playerAddUerDefineDestructableKv(player, "hitDestructable", hitCube.actor._base)
				player.hitCube = hitCube
				player.hitcubePlaneName = hitcubePlaneName
			else
				playerAddUerDefineDestructableKv(player, "hitDestructable", nil)
				player.hitCube = nil
				player.hitcubePlaneName = nil
			end
		end
		for _, v in pairs(hitCubeArr) do
			if not Cube:isExistChooseParticle(v) then
				Cube:creatChooseParticle(v)
			end
		end
		local diffArr = Util:valueDiff(hitCubeArr, Cube:getAllCube())
		for _, cube in pairs(diffArr) do
			Cube:removeChooseParticle(cube)
		end
	end

	-- 建造方块
	function buildBlock(trigger, ...)
		local player = ...
		local chooseItemId = getPlayerCurUseItemSlotId(player, "chooseItemId")
		local cubeId = {
			[2] = 134273901, -- 灰
			[3] = 134239615, -- 红
			[5] = 134232679, -- 黑
			[6] = 134245094, -- 褐
			[7] = 134266735, -- 蓝
			[8] = 134248315, -- 商店
			[9] = 134236705, -- 资源点
			[10] = 134266085 -- 出生点
		}
		local key = cubeId[chooseItemId]
		if not key then
			return
		end
		local unitId = getPlayerBindUnitId(player, "UNIT")
		local unit = Unit:getUnit(unitId)
		if unit.actor:has_tag("buying") then
			return
		end
		-- 放置动作
		unit.actor:add_animation({
			init_time = 0,
			end_time = -1,
			loop = false,
			speed = 3,
			name = "attack1",
			return_idle = false
		})
		local hitCube, hitPlaneName = player.hitCube, player.hitcubePlaneName
		if hitCube then
			local centerPoint = nil
			local buffer = 2 -- 数据误差纠正
			if hitPlaneName == "TOP" then
				centerPoint = {
					x = hitCube.cubeModel.centerPoint.x,
					y = hitCube.cubeModel.centerPoint.y,
					z = hitCube.cubeModel.centerPoint.z + hitCube.cubeModel.height - buffer
				}
			elseif hitPlaneName == "BOTTOM" then
				centerPoint = {
					x = hitCube.cubeModel.centerPoint.x,
					y = hitCube.cubeModel.centerPoint.y,
					z = hitCube.cubeModel.centerPoint.z - hitCube.cubeModel.height + buffer
				}
			elseif hitPlaneName == "LEFT" then
				centerPoint = {
					x = hitCube.cubeModel.centerPoint.x - hitCube.cubeModel.length + buffer,
					y = hitCube.cubeModel.centerPoint.y,
					z = hitCube.cubeModel.centerPoint.z
				}
			elseif hitPlaneName == "RIGHT" then
				centerPoint = {
					x = hitCube.cubeModel.centerPoint.x + hitCube.cubeModel.length - buffer,
					y = hitCube.cubeModel.centerPoint.y,
					z = hitCube.cubeModel.centerPoint.z
				}
			elseif hitPlaneName == "FRONT" then
				centerPoint = {
					x = hitCube.cubeModel.centerPoint.x,
					y = hitCube.cubeModel.centerPoint.y + hitCube.cubeModel.width - buffer,
					z = hitCube.cubeModel.centerPoint.z
				}
			elseif hitPlaneName == "BACK" then
				centerPoint = {
					x = hitCube.cubeModel.centerPoint.x,
					y = hitCube.cubeModel.centerPoint.y - hitCube.cubeModel.width + buffer,
					z = hitCube.cubeModel.centerPoint.z
				}
			end
			-- 单位所在位置无法放置
			local length = 300
			local width = 300
			local height = 300
			local cubeModel = Util:creatCubeModel(centerPoint, length, width, height)
			for _, u in pairs(Unit.instanceArr) do
				unitPoint = Unit:getUnitCenterPoint(u)
				local unitBottomPoint = Unit:getUnitBottomPoint(u)
				local unitTopPoint = Unit:getUnitTopPoint(u)
				if Util:isPointInCube(unitPoint, cubeModel) or
					Util:isPointInCube(unitBottomPoint, cubeModel) or
					Util:isPointInCube(unitTopPoint, cubeModel) then
					player:msg("单位位置无法放置")
					return
				end
				if u.standCube and hitCube.key == u.standCube.key and hitPlaneName == "TOP" and
					unitBottomPoint.z - hitCube.cubeModel.p1.z <= Cube:getCubeModelHeight() then
					player:msg("单位位置无法放置")
					return
				end
			end
			-- 防止重复位置放置
			for _, cube in pairs(Cube:getAllCube()) do
				repeat
					if Util:distance(cube.cubeModel.centerPoint, centerPoint) > unit.height * 2.5 then
						break
					end
					if Util:equal(cube.cubeModel.centerPoint, centerPoint) then
						player:msg("重复放置")
						return
					end
				until true
			end
			-- player:msg(hitPlaneName)
			-- creatLinkEffect(100579, originPoint, intersectionPoint) -- 红色
			-- creatLinkEffect(100316, originPoint, hitCube.cubeModel.centerPoint) -- 绿色
			-- creatLinkEffect(103668, originPoint, getMouseWorldPoint(player)) -- 蓝色
			local buildItem = unit.actor:get_item("Inventory", chooseItemId)
			local buildItemStack = buildItem:get_stack()
			if buildItemStack > 0 then
				local cube = Cube:creatCube(centerPoint, length, width, height, key, cubeModel)
				player:play_3d_sound({
					key = 134239397,
					point = up.point(centerPoint.x, centerPoint.y, 0),
					height = centerPoint.z - unit.height / 2,
					fadeIn = 0,
					fadeOut = 0,
					cycle = false,
					insure = true
				})
				local isTest = getTrigerGloableVar("isManager")
				if not isTest then
					buildItem:add_stack(-1)
					buildItemStack = buildItemStack - 1
				end
				-- 测试环境下增加床块
				if isTest then
					if chooseItemId == 5 or chooseItemId == 10 then -- 创建床块或者出生点
						-- 区分创建cube的所属阵营
						local campKey = "CUBECAMP" -- 在T中绑定的该值
						if isPlayerExitStringKv(player, campKey) then
							local camp = getPlayerBindString(player, campKey)
							if camp == "阵营1" then
								cube.camp = up.team(1)
								if chooseItemId == 5 then
									table.insert(campOneBlackCubeArr, cube)
								end
							elseif camp == "阵营2" then
								cube.camp = up.team(2)
								if chooseItemId == 5 then
									table.insert(campTwoBlackCubeArr, cube)
								end
							end
						else
							cube.camp = up.team(1)
							if chooseItemId == 5 then
								table.insert(campOneBlackCubeArr, cube)
							end
						end
					end
				end
				local storeTable = gameapi.get_table("store")
				storeTable[cube.key] = vectorToString(cube) -- 缓存cube构造信息
			end
		end
	end

	-- 销毁方块
	function destroyBlock(trigger, ...)
		--- @type Player
		local player = ...
		local unitId = getPlayerBindUnitId(player, "UNIT")
		local unit = Unit:getUnit(unitId)
		if unit.actor:has_tag("buying") then
			return
		end
		local uid = "3b77f13c-c9d6-4980-9448-dd641a85606d" -- 破坏进度UI
		local animationUid = 1
		local dataTable = GameAPI.get_table("public")
		local hitCube = player.hitCube
		local isTest = getTrigerGloableVar("isManager")
		local typeArr = {
			[2] = 134273901, -- 灰
			[3] = 134239615, -- 红
			[5] = 134232679, -- 黑
			[6] = 134245094, -- 褐
			[7] = 134266735, -- 蓝
			[8] = 134248315, -- 商店
			[9] = 134236705, -- 资源点
			[10] = 134266085 -- 出生点
		}
		if not isTest and (
			hitCube.type ~= "type:" .. typeArr[2] and hitCube.type ~= "type:" .. typeArr[3] and
				hitCube.type ~= "type:" .. typeArr[5]) or
			not hitCube then
			return
		end
		-- 破坏动作
		unit.actor:add_animation({
			init_time = 0,
			end_time = -1,
			loop = true,
			speed = 3,
			name = "attack1",
			return_idle = false
		})
		local cd = 3
		local speed = 1
		local SPEED = 1.75
		local sound = nil
		if hitCube then
			if hitCube.type == "type:" .. typeArr[2] then
				cd = dataTable["灰色cube破坏时间（second）"]:float()
			elseif hitCube.type == "type:" .. typeArr[3] then
				cd = dataTable["红色cube破坏时间（second）"]:float()
			elseif hitCube.type == "type:" .. typeArr[5] then
				cd = dataTable["黑色cube破坏时间（second）"]:float()
			else
				cd = 0
				unit.actor:stop_animation("attack1")
			end
			speed = SPEED / (cd == 0 and 0.1 or cd)
		end
		local t = 0
		local hitCubeTemp = nil -- 缓存选中的cube,用于切换cube的时候重置计时
		up.loop(0.1, function(timer)
			hitCube = player.hitCube
			-- 破坏目标切换
			if hitCubeTemp and hitCube and hitCubeTemp.key ~= hitCube.key then
				t = 0
				if hitCube.type == "type:" .. typeArr[2] then
					cd = dataTable["灰色cube破坏时间（second）"]:float()
				elseif hitCube.type == "type:" .. typeArr[3] then
					cd = dataTable["红色cube破坏时间（second）"]:float()
				elseif hitCube.type == "type:" .. typeArr[5] then
					cd = dataTable["黑色cube破坏时间（second）"]:float()
				else
					cd = 0
					unit.actor:stop_animation("attack1")
				end
				if isTest then
					cd = 0
				end
				speed = SPEED / (cd == 0 and 0.1 or cd)
				up.ui:stop_ui_comp_anim(player, animationUid)
			end
			if isTest then
				cd = 0
				speed = SPEED / (cd == 0 and 0.1 or cd)
			end
			hitCubeTemp = hitCube
			if t == 0 and hitCube and cd ~= 0 then
				up.ui:play_ui_comp_anim(player, animationUid, speed)
				up.ui:show(uid, "", player)
			end
			if hitCube then
				t = t + 0.1
			end
			-- 提醒床被破坏
			local cubeType = "type:" .. typeArr[5] -- 黑
			local isDestoryOnselfCmapBlackCube = nil
			local tipUid = "bfc22998-fa6f-4502-b803-8a19feb4a35a"
			if not isTest and hitCube and hitCube.camp then
				isDestoryOnselfCmapBlackCube = (hitCube.camp:get_id() == player:get_team():get_id())
				if hitCube.type == cubeType then
					if not isDestoryOnselfCmapBlackCube then
						for _, v in pairs(hitCube.camp:get_all_player()) do
							up.ui:show(tipUid, "", v)
							if v.uiTimer then
								v.uiTimer:remove()
								v.uiTimer = up.wait(1, function()
									up.ui:hide(tipUid, "", v)
								end)
							else
								v.uiTimer = up.wait(1, function()
									up.ui:hide(tipUid, "", v)
								end)
							end
						end
					end
				end
			end
			-- 破坏己方床块提示
			local destoryOneselfTipUid = "9ad7afe1-439b-4481-9cd0-de73ae9b5d3a"
			if isDestoryOnselfCmapBlackCube then
				up.ui:show(destoryOneselfTipUid, "", player)
			else
				up.ui:hide(destoryOneselfTipUid, "", player)
			end
			-- 进度条控制
			local isPressRight = player:is_key_pressed("MOUSE-RIGHT")
			local isNotCanDestory = nil
			if hitCube then
				if hitCube.type == "type:" .. typeArr[6] or hitCube.type == "type:" .. typeArr[7] then
					isNotCanDestory = true
				end
			end
			if not isPressRight or not hitCube or isDestoryOnselfCmapBlackCube or isNotCanDestory then
				up.ui:hide(uid, "", player)
				up.ui:stop_ui_comp_anim(player, animationUid)
				-- 不破坏
				if not hitCube or isDestoryOnselfCmapBlackCube or isNotCanDestory then
					t = 0
				end
				-- 停止破坏
				if not isPressRight then
					up.ui:hide(destoryOneselfTipUid, "", player)
					unit.actor:stop_animation("attack1")
					timer:remove()
				end
			end
			if t > cd and hitCube then
				t = 0
				player:play_3d_sound({
					key = 134239397,
					point = up.point(hitCube.cubeModel.centerPoint.x, hitCube.cubeModel.centerPoint.y, 0),
					height = hitCube.cubeModel.centerPoint.z - unit.height / 2,
					fadeIn = 0,
					fadeOut = 0,
					cycle = false,
					insure = true
				})
				up.ui:hide(uid, "", player)
				up.ui:stop_ui_comp_anim(player, animationUid)
				-- 脚下方块被破坏
				if Util:equal(hitCube, unit.standCube) then
					unit.standCube = nill
					unit.state = "SKY"
				end
				-- 破坏床块
				if hitCube.type == cubeType then
					if hitCube.camp:get_id() == 1 then
						for k, v in pairs(campOneBlackCubeArr) do
							if v.camp:get_id() == hitCube.camp:get_id() then
								table.remove(campOneBlackCubeArr, k)
								break
							end
						end
						if Util:getTableLength(campOneBlackCubeArr) <= 0 and not isTest then
							Cube:remove(hitCube)
							unit.actor:stop_animation()
							up.wait(0.5, function()
								for _, v in pairs(up.team(2):get_all_player()) do
									v:game_bad()
								end
								for _, v in pairs(up.team(1):get_all_player()) do
									v:game_win()
								end
							end)
						end
					elseif hitCube.camp:get_id() == 2 then
						for k, v in pairs(campTwoBlackCubeArr) do
							if v.camp:get_id() == hitCube.camp:get_id() then
								table.remove(campTwoBlackCubeArr, k)
								break
							end
						end
						if Util:getTableLength(campTwoBlackCubeArr) <= 0 and not isTest then
							Cube:remove(hitCube)
							unit.actor:stop_animation()
							up.wait(0.5, function()
								for _, v in pairs(up.team(2):get_all_player()) do
									v:game_bad()
								end
								for _, v in pairs(up.team(1):get_all_player()) do
									v:game_win()
								end
							end)
						end
					end
				end
				local storeTable = gameapi.get_table("store")
				storeTable[hitCube.key] = nil
				local slot = nil
				for k, v in pairs(typeArr) do
					if "type:" .. tostring(v) == hitCube.type then
						slot = k
					end
				end
				local hitItem = unit.actor:get_item("Inventory", slot)
				if hitCube.type == "type:" .. typeArr[2] or hitCube.type == "type:" .. typeArr[3] then
					hitItem:add_stack(1)
				end
				Cube:remove(hitCube)
			end
		end)
	end

	-- 物理系统
	function physicalSystem(...)
		local unitArr = ...
		local rayController = 0
		local logicFram = 1 / GameAPI.get_table("public")["LOGICFRAM"]:float()
		up.loop(logicFram, function(timer)
			chooseParticle(unitArr) -- 优化, 选中特效
			--- @type Unit
			for _, unit in pairs(unitArr) do
				repeat
					unit.actor:set("ori_speed", unit.v)
					local unitPoint = Unit:getUnitCenterPoint(unit)
					local unitWidth = unit.width -- unitWidth < cubeModel的min(length, width)
					local buffer = 4 -- buffer = 浮点数修正值 + 弹性碰撞的阻力 < bufferCube的buffer值/2 = 5
					-- 水平探测碰撞检测
					local player = getUnitBindPlayer(unit, "PLAYER")
					local isPressW = player:is_key_pressed("W")
					local isPressS = player:is_key_pressed("S")
					local isPressA = player:is_key_pressed("A")
					local isPressD = player:is_key_pressed("D")
					local mvoeDirection = getUnitMoveDirection(player, unit)
					local offsetPoint = getPointHorizontalOffsetPoint(unitPoint, mvoeDirection, unitWidth)
					local offsetBottomPoint = getPointHorizontalOffsetPoint(Unit:getUnitBottomPoint(unit), mvoeDirection, unitWidth)
					local offsetTopPoint = getPointHorizontalOffsetPoint(Unit:getUnitTopPoint(unit), mvoeDirection, unitWidth)
					if Cube:isCollision({ offsetPoint, offsetBottomPoint, offsetTopPoint }, unit.height * 2.5) then
						unitStopMove(unit)
						unit.actor:add_tag("notMove")
					else
						unit.actor:remove_tag("notMove")
					end
					-- 实际碰撞检测
					local collisionCubeArrAndPlaneArr = Cube:getCollisionCubeAndPlane(unit) -- 获取碰撞立方体数组和最近面数组
					-- 标记碰撞类型
					if collisionCubeArrAndPlaneArr then
						--- @type table<string, Plane>
						for k, plane in pairs(collisionCubeArrAndPlaneArr[2]) do
							if plane.name == "TOP" then
								unit.collisionType.topCollision = true
								unitAddUerDefineBoolenKv(unit, "topCollision", true)
								unit.state = "LAND"
								--- @type Cube
								unit.standCube = collisionCubeArrAndPlaneArr[1][k]
								unit.jumpInitHeight = Unit:getUnitBottomPoint(unit).z
							elseif plane.name == "BOTTOM" then
								unit.collisionType.bottomCollision = true
								unitAddUerDefineBoolenKv(unit, "bottomCollision", true)
								unit.jumpInitHeight = Unit:getUnitBottomPoint(unit).z
							elseif plane.name == "LEFT" then
								unit.collisionType.leftCollision = true
								unitAddUerDefineBoolenKv(unit, "leftCollision", true)
							elseif plane.name == "RIGHT" then
								unit.collisionType.rightCollision = true
								unitAddUerDefineBoolenKv(unit, "rightCollision", true)
							elseif plane.name == "FRONT" then
								unit.collisionType.frontCollision = true
								unitAddUerDefineBoolenKv(unit, "frontCollision", true)
							elseif plane.name == "BACK" then
								unit.collisionType.backCollision = true
								unitAddUerDefineBoolenKv(unit, "backCollision", true)
							end
						end
					end
					-- 全局重力
					unit.time = unit.time + logicFram
					if unit.collisionType.bottomCollision then
						unit.vg = -unit.vg
						unit.time = logicFram
					end
					-- 不受重力
					if unit.state == "SNEAK" or (isUnitExitBooleanKv(unit.actor, "不受重力") and
						getUnitBindBoolean(unit.actor, "不受重力")) then
						unit.time = 0
						unit.vg = 0
						unit.jumpInitHeight = Unit:getUnitBottomPoint(unit).z
					end
					-- 计算目标高度
					local h = caculatCurUnitWorldHeightByGravity(unit, unit.time)
					-- player:msg(h)
					-- 避免量子隧穿,即物理穿透问题,但消耗性能
					if (isPressW or isPressS or isPressA or isPressD or unit.state == "SKY") and
						GameAPI.get_table("public")["ISENABLECONTINUECOLLISION"] then -- 优化
						local ray = Util:creatRay(Unit:getUnitBottomPoint(unit), Util:creatVector(0, 0, -10))
						local hitCube, intersectionPoint, hitPlaneName = Cube:getRayHitCubeInfo(ray, unit.height * 6) -- 增加连续判定范围
					end
					local minH = hitCube and (hitCube.cubeModel.p1.z + buffer) or h
					if minH > h then
						unit.collisionType.topCollision = true
						h = minH
					end
					local minCube = Cube:isCollision({ Unit:getUnitBottomPoint(unit) }, unit.height * 2.5) -- 弥补缝隙穿透问题
					if minCube then
						h = minCube.cubeModel.p1.z + buffer
					end
					-- 落地
					if unit.collisionType.topCollision then
						unit.jumpInitHeight = Unit:getUnitBottomPoint(unit).z
						unit.time = 0
						unit.vg = 0
						-- 扣血
						local maxVg = getHToSVg(4 * Cube:getCubeModelHeight())
						local cruVg = math.abs(unit.curVg)
						if cruVg >= maxVg then
							unitPoint = Unit:getUnitCenterPoint(unit)
							local curHp = unit.actor:get("hp_cur")
							local damageTemp = (cruVg - maxVg) * 0.4
							local damage = damageTemp > curHp and curHp or damageTemp
							if damage > unit.actor:get("hp_max") * 0.1 then
								player:play_3d_sound({
									key = 134268729,
									point = up.point(unitPoint.x, unitPoint.y, 0),
									height = unitPoint.z - unit.height / 2,
									fadeIn = 0,
									fadeOut = 0,
									cycle = false,
									insure = true
								})
								unit.actor:add_damage({ -- 该API不会触发单位受到伤害事件
									damage = damage,
									jump_word = false,
									type = 0
								})
								unit.actor:new_buff({
									id = 134221396,
									time = 0.3
								})
							end
						end
					end
					-- 潜行
					local isPressCtrl = player:is_key_pressed("LCTRL")
					-- 状态切换: 陆地->潜行
					if unit.state == "LAND" and -- 悬崖
						(Unit:getUnitBottomPoint(unit).z - minH > Cube:getCubeModelHeight() / 2 or not hitCube) and -- 避免cube间隙
						isPressCtrl then
						unit.state = "SNEAK"
					else
						-- 状态切换: 潜行->悬空
						if unit.state == "SNEAK" and not isPressCtrl then
							unit.state = "SKY"
						end
						if not (isUnitExitBooleanKv(unit.actor, "不受重力") and getUnitBindBoolean(unit.actor, "不受重力")) then
							unit.actor:set_height(h) -- 设置高度
						end
					end
					-- 限制移动范围
					if unit.state == "SNEAK" and unit.standCube and not unit.actor:has_tag("hited") then
						unitPoint = Unit:getUnitCenterPoint(unit)
						local minX = unit.standCube.cubeModel.p1.x - unit.width * 1.1
						local maxX = unit.standCube.cubeModel.p2.x + unit.width * 1.1
						local minY = unit.standCube.cubeModel.p1.y - unit.width * 1.1
						local maxY = unit.standCube.cubeModel.p4.y + unit.width * 1.1
						local x = nil
						local y = nil
						if unitPoint.x < minX then
							x = minX
						end
						if unitPoint.x > maxX then
							x = maxX
						end
						if unitPoint.y < minY then
							y = minY
						end
						if unitPoint.y > maxY then
							y = maxY
						end
						unit.actor:set_point(up.point(x or unitPoint.x, y or unitPoint.y))
					end
					-- 单位掉落下限相关
					local mindieHeight = GameAPI.get_table("public")["死亡高度"]:float()
					if unitPoint.z - unit.height / 2 < mindieHeight and unit.actor:is_alive() then
						unit.actor:kill()
					end
					-- 物理效果
					if collisionCubeArrAndPlaneArr then
						-- player:msg("collision")
						-- 处理卡死
						local count = 0
						for _, v in pairs(unit.collisionType) do
							if v then
								count = count + 1
							end
						end
						if count >= 5 then
							-- player:msg("卡死")
							-- unit.actor:kill()
							if unit.standCube then
								local point = unit.standCube.cubeModel.centerPoint
								unit.actor:set_height(point.z + Cube:getCubeModelHeight() / 2)
								unit.actor:set_point(up.point(point.x, point.y, 0))
							end
							break
						end
						if unit.collisionType.topCollision and unit.collisionType.bottomCollision or
							unit.collisionType.leftCollision and unit.collisionType.rightCollision or
							unit.collisionType.frontCollision and unit.collisionType.backCollision then
							-- player:msg("卡死")
							if unit.standCube then
								local point = unit.standCube.cubeModel.centerPoint
								unit.actor:set_height(point.z + Cube:getCubeModelHeight() / 2)
								unit.actor:set_point(up.point(point.x, point.y, 0))
							end
							-- unit.actor:kill()
							break
						end
						-- 物理碰撞
						--- @param collisionCube Cube
						for k, collisionCube in pairs(collisionCubeArrAndPlaneArr[1]) do
							unitPoint = Unit:getUnitCenterPoint(unit)
							local minDistancePlaneName = collisionCubeArrAndPlaneArr[2][k].name
							-- player:msg(minDistancePlaneName)
							-- print(minDistancePlaneName)
							-- 计算新位置
							local newUnitPoint = nil
							if minDistancePlaneName == "TOP" then
								newUnitPoint = Util:creatVector(
									unitPoint.x,
									unitPoint.y,
									collisionCube.cubeModel.p1.z + unit.height / 2 + buffer
								)
							elseif minDistancePlaneName == "BOTTOM" then
								newUnitPoint = Util:creatVector(
									unitPoint.x,
									unitPoint.y,
									collisionCube.cubeModel.p5.z - unit.height / 2 - buffer
								)
							elseif minDistancePlaneName == "LEFT" then
								newUnitPoint = Util:creatVector(
									collisionCube.cubeModel.p1.x - unitWidth / 2,
									unitPoint.y,
									unitPoint.z
								)
							elseif minDistancePlaneName == "RIGHT" then
								newUnitPoint = Util:creatVector(
									collisionCube.cubeModel.p2.x + unitWidth / 2,
									unitPoint.y,
									unitPoint.z
								)
							elseif minDistancePlaneName == "FRONT" then
								newUnitPoint = Util:creatVector(
									unitPoint.x,
									collisionCube.cubeModel.p3.y + unitWidth / 2,
									unitPoint.z
								)
							elseif minDistancePlaneName == "BACK" then
								newUnitPoint = Util:creatVector(
									unitPoint.x,
									collisionCube.cubeModel.p2.y - unitWidth / 2,
									unitPoint.z
								)
							end
							-- 设置碰撞后的位置
							if newUnitPoint then
								if unit.collisionType.topCollision or unit.collisionType.bottomCollision then
									unit.actor:set_height(newUnitPoint.z - unit.height / 2)
								end
								if unit.collisionType.leftCollision or unit.collisionType.rightCollision or
									unit.collisionType.frontCollision or unit.collisionType.backCollision then
									local pointActor = up.point(newUnitPoint.x, newUnitPoint.y)
									unitStopMove(unit)
									unit.actor:set_point(pointActor)
								end
							end
						end
					end
					resetUnitCollisionType(unit)
				until true
			end
		end)
	end

	-- 单位跳跃
	function unitJump(trigger, ...)
		local argArr = ...
		local player, key = ...
		if key == KEY["SPACE"] then
			local unit = Unit:getUnit(getPlayerBindUnitId(player, "UNIT"))
			if (isUnitExitBooleanKv(unit.actor, "不受重力") and getUnitBindBoolean(unit.actor, "不受重力")) then
				return
			end
			if unit.state == "LAND" or unit.state == "SNEAK" then
				unit.vg = getUnitBindFloat(unit, "VG")
				unit.state = "SKY"
				unit.standCube = nil
				unit.actor:set_height(Unit:getUnitBottomPoint(unit).z + 6) -- 脱离缓冲层
				unit.jumpInitHeight = Unit:getUnitBottomPoint(unit).z -- 缓存初始跳跃高度
			end
		end
	end

	-- 初始化场景
	function initScene()
		local length = 300
		local width = 300
		local height = 300
		local player = up.player(1) -- 默认使用玩家一的存档
		if player._base then
			local storeTableTemp = player:get_save_data_table_value(1)
			local storeTable = storeTableTemp["0"] and storeTableTemp or require("MC.STORE") -- 存档的数据
			local curStoreTable = GameAPI.get_table("store") -- 缓存数据表
			local areaTable = {} -- 存储区域表
			local CUBEMAXPOINT = Util:creatVector(0, 0, 0)
			local playerInfoTable = GameAPI.get_table("playerInfo")
			for _, str in pairs(storeTable) do
				if str and str ~= "" then
					local centerPointX, centerPointY, centerPointZ, cubeType, campId = Util:split(str, "|")
					if centerPointX and centerPointY and centerPointZ and cubeType then
						x = tonumber(centerPointX)
						y = tonumber(centerPointY)
						z = tonumber(centerPointZ)
						if CUBEMAXPOINT.z < z then
							CUBEMAXPOINT.z = z + Cube:getCubeModelHeight() / 2 + 10
							CUBEMAXPOINT.x = x
							CUBEMAXPOINT.y = y
						end
						local centerPoint = Util:creatVector(x, y, z)
						local key = math.floor(tonumber(cubeType))
						local id = nil
						local realCampId = campId and math.floor(tonumber(campId)) or nil
						local replaceKeyArr = {
							[1] = 134248315, -- 商店
							[2] = 134236705, -- 资源点
							[3] = 134266085 -- 出生点
						}
						-- 判定是否属于替换资源,即非cube类型
						local zTemp = z - Cube:getCubeModelHeight() / 2
						if Util:valueInTable(key, replaceKeyArr) then
							if key == replaceKeyArr[1] then
								local unitKey = 134251135
								local angle = up.point(x, y, 0) / up.point(-6105, -9303, 0)
								local actor = up.create_unit(unitKey, up.point(x, y, 0), angle, up.player(31))
								actor:set_height(zTemp)
							elseif key == replaceKeyArr[2] then
								local publicTable = GameAPI.get_table("public")
								local range = publicTable["资源点范围"]:float()
								local area = up.creat_area(up.point(x, y, 0), range)
								local areaId = area:get_id()
								areaTable[tostring(areaId)] = areaId -- T用的id作为实体去执行的函数
								areaAddUerDefineFloatKv(area, "height", zTemp)
							elseif key == replaceKeyArr[3] then
								-- playerInfoTable["point"] = x .. "|" .. y .. "|" .. z
								-- 区分创建cube的所属阵营
								if realCampId == 1 then
									playerInfoTable["campOneSpawn"] = x .. "|" .. y .. "|" .. z
								elseif realCampId == 2 then
									playerInfoTable["campTwoSpawn"] = x .. "|" .. y .. "|" .. z
								end
							end
							Cube.length = Cube.length + 1
						else
							local cube = Cube:creatCube(centerPoint, length, width, height, key, nil, id, realCampId)
							if realCampId == 1 then
								table.insert(campOneBlackCubeArr, cube)
							elseif realCampId == 2 then
								table.insert(campTwoBlackCubeArr, cube)
							end
						end
						curStoreTable[tostring(Cube.length)] = str -- 缓存上一存档数据
					else
						Cube.length = Cube.length + 1
					end
				end
			end
			setTrigerGloableVar("areaTable", areaTable)
			playerInfoTable["point"] = CUBEMAXPOINT.x .. "|" .. CUBEMAXPOINT.y .. "|" .. CUBEMAXPOINT.z
			-- print(Cube.length) -- 包含被替换的cube
		end
	end

	-- 游戏初始化开始
	function gameInitBegin(trigger)
		gameapi.force_enable_camera_sync(true) -- 启动镜头强制同步
		initScene()
		local dataTable = gameapi.get_table("public")
		g = dataTable["人物降落速度"]:float() -- 全局重力加速度
		physicalSystem(Unit.instanceArr)
	end

	--[[
		事件
	---]]

	up.game:event("Game-Init", gameInitBegin)

	up.game:event("Mouse-RightDown", destroyBlock)

	up.game:event("Mouse-LeftDown", buildBlock)

	up.game:event("Keyboard-Down", unitJump)

	-- game_api.get_input_field_content(up.player(1)._base, "1100e6de-f363-4249-9048-d6e6c65de896")
	-- local t = 0
	-- up.game:event("Mouse-LeftDown", function()
	-- local unit = Unit:getUnit(3)
	-- up.loop(0.033, function(timer)
	-- 	t = t + 0.033
	-- 	-- print(type(unit.actor._base)) -- userdata
	-- 	-- unit.actor._base.a = 1
	-- 	-- print(unit.actor._base.a)
	-- 	local n = GlobalAPI.interpolate(-405, 1000, Fix32(t)):float()
	-- 	-- print(n)
	-- 	local x, y = unit.actor:get_point():get()
	-- 	y = y + n
	-- 	unit.actor:set_point(up.point(x, y))
	-- 	if t >= 1 then
	-- 		timer:remove()
	-- 	end
	-- end)
	-- local dic = pydict()
	-- print(dic)
	-- print(type(dic))
	-- dic["__121"] = "121"
	-- dic["_wqeq"] = "afaf"
	-- -- logout(dic)
	-- for _, v in Python.enumerate(dic, 1) do
	-- 	print(v, dic[v])
	-- end
	-- print(dic["_wqeq"])
	-- print(gameapi.get_player_plat_aid(up.player(1)._base))
	-- end)

	-- local a = {
	-- 	a = 1
	-- }
	-- function valueUpdateEvent(t)
	-- 	local meta = {
	-- 		__index = t,
	-- 		__newindex = function(tb, key, value)
	-- 			print("值更新了")
	-- 			local mt = getmetatable(tb)
	-- 			setmetatable(tb, {})
	-- 			tb[key] = value
	-- 			setmetatable(tb, mt)
	-- 		end
	-- 	}
	-- 	return setmetatable({}, meta)
	-- end
	-- local t = valueUpdateEvent(a)
	-- t.a = 2
	-- print(t.a)
	-- t.b = 1
	-- print(t.b)
end
