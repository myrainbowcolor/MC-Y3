--- @type table<integer, Cube>
_gAllCube = {} -- 存在的所有立方体对象

--- @class Cube
--- @field cubeModel CubeModel
--- @field bufferCube CubeModel
--- @field actor Actor
--- @field key string
--- @field type string
--- @field chooseParticles table<string, Particle>
--- @field length integer
--- @field camp team
Cube = {} -- 立方体类
Cube.length = 0 -- 自增索引

-- 构造立方体, 顶点顺序:从下到上按顺时针排序
--- @param centerPoint Vector
--- @param length number
--- @param width number
--- @param height number
--- @param key integer
--- @param cubeModel CubeModel|nil
--- @param id integer|nil
--- @param campId integer|nil
--- @return Cube
function Cube:creatCube(centerPoint, length, width, height, key, cubeModel, id, campId)
	local cube = {}
	cube.cubeModel = cubeModel or Util:creatCubeModel(centerPoint, length, width, height)
	-- cube.actor = up.create_destructable(key, up.point(centerPoint.x, centerPoint.y, (centerPoint.z - height / 2) / 2), 0, 1)
	cube.actor = up.create_destructable(key, up.point(centerPoint.x, centerPoint.y, centerPoint.z - height / 2), 0, 1)
	cube.bufferCube = Util:creatCubeModel(centerPoint, length, width, height + 10)
	Cube.length = Cube.length + 1
	cube.key = tostring(id or Cube.length)
	cube.type = "type:" .. cube.actor:get_key()
	cube.chooseParticles = {
		topParticle = nil,
		bottomParticle = nil,
		leftParticle = nil,
		rightParticle = nil,
		frontParticle = nil,
		backParticle = nil
	}
	cube.camp = campId and up.team(campId) or nil -- 所属阵营
	cube.isChooseed = false
	_gAllCube[id or Cube.length] = cube
	return cube
end

-- 是否存在选中特效
--- @param cube Cube
--- @return boolean
function Cube:isExistChooseParticle(cube)
	for _, v in pairs(cube.chooseParticles) do
		if v then
			return true
		end
	end
	return false
end

-- 获取所有立方体
--- @return table<integer, Cube>
function Cube:getAllCube()
	return _gAllCube
end

-- 清除立方体的选中特效
--- @param cube Cube
function Cube:removeChooseParticle(cube)
	for k, v in pairs(cube.chooseParticles) do
		if v then
			cube.chooseParticles[k]:set_scale(0, 0, 0)
			cube.chooseParticles[k]:remove()
			cube.chooseParticles[k] = nil
		end
	end
end

-- 创建Cube的选中特效
--- @param cube Cube
function Cube:creatChooseParticle(cube)
	-- 上
	--- @class Particle
	local topParticle = up.particle({
		id = 134276632,
		target = cube.actor:get_point(),
		angle = 0,
		scale = 0.6,
		height = cube.cubeModel.p1.z,
		time = -1
	})
	cube.chooseParticles.topParticle = topParticle
	-- 下
	--- @class Particle
	local bottomParticle = up.particle({
		id = 134276632,
		target = cube.actor:get_point(),
		angle = 0,
		scale = 0.6,
		height = cube.cubeModel.p5.z,
		time = -1
	})
	bottomParticle:set_rotate(180, 0, 0)
	cube.chooseParticles.bottomParticle = bottomParticle
	-- 左
	--- @class Particle
	local leftParticle = up.particle({
		id = 134276632,
		target = up.point(
			cube.cubeModel.centerPoint.x - cube.cubeModel.length / 2 + 10,
			cube.cubeModel.centerPoint.y,
			cube.cubeModel.centerPoint.z
		),
		angle = 0,
		scale = 0.6,
		height = cube.cubeModel.centerPoint.z,
		time = -1
	})
	leftParticle:set_rotate(0, 90, 0)
	cube.chooseParticles.leftParticle = leftParticle
	-- 右
	--- @class Particle
	local rightParticle = up.particle({
		id = 134276632,
		target = up.point(
			cube.cubeModel.centerPoint.x + cube.cubeModel.length / 2 - 10,
			cube.cubeModel.centerPoint.y,
			cube.cubeModel.centerPoint.z
		),
		angle = 0,
		scale = 0.6,
		height = cube.cubeModel.centerPoint.z,
		time = -1
	})
	rightParticle:set_rotate(0, -90, 0)
	cube.chooseParticles.rightParticle = rightParticle
	-- 前
	--- @class Particle
	local frontParticle = up.particle({
		id = 134276632,
		target = up.point(
			cube.cubeModel.centerPoint.x,
			cube.cubeModel.centerPoint.y + cube.cubeModel.height / 2 - 10,
			cube.cubeModel.centerPoint.z
		),
		angle = 0,
		scale = 0.6,
		height = cube.cubeModel.centerPoint.z,
		time = -1
	})
	frontParticle:set_rotate(90, 0, 0)
	cube.chooseParticles.frontParticle = frontParticle
	-- 后
	--- @class Particle
	local backParticle = up.particle({
		id = 134276632,
		target = up.point(
			cube.cubeModel.centerPoint.x,
			cube.cubeModel.centerPoint.y - cube.cubeModel.height / 2 + 10,
			cube.cubeModel.centerPoint.z
		),
		angle = 0,
		scale = 0.6,
		height = cube.cubeModel.centerPoint.z,
		time = -1
	})
	backParticle:set_rotate(-90, 0, 0)
	cube.chooseParticles.backParticle = backParticle
	cube.isChooseed = true
end

-- 删除立方体
--- @param cube Cube
function Cube:remove(cube)
	self:removeChooseParticle(cube)
	cube.actor:remove()
	local index = math.floor(tonumber(cube.key))
	_gAllCube[index] = nil
end

-- 获取射线打中的最近的立方体, 交点和面名,参数2为忽略对象数组
--- @param ray Ray
--- @param ignoreArr table<integer, Cube>|nil
--- @param detectDistance number|nil
--- @return Cube, Vector, string
-- O(n)
function Cube:getRayHitCubeInfo(ray, detectDistance, ignoreArr)
	if not ray then error("EG=> argument 1 is nil") end
	if type(ray) ~= "table" then error("argument 1 type is not table") end
	if ignoreArr and type(ignoreArr) ~= "table" then
		error("argument 2 type is not table<integer, Cube>")
	end
	local cubeTb = nil
	if not ignoreArr and Util:getTableLength(ignoreArr) ~= 0 then
		cubeTb = Util:valueDiff(_gAllCube, ignoreArr)
	else
		cubeTb = _gAllCube
	end

	local minDistance = math.maxinteger
	local resCube = nil
	local resIntersectionPoint = nil
	local resPlaneName = nil
	--- @param cube Cube
	for _, cube in pairs(cubeTb) do
		repeat
			if Util:distance(cube.cubeModel.centerPoint, ray.origin) > detectDistance then -- 优化, 缩减探测范围
				break
			end
			local intersectionPoint, planeName = Util:getRayHitCubeInersectionPointAndPlaneName(ray, cube.cubeModel)
			if not intersectionPoint or not planeName then break end
			local curDistance = Util:distance(ray.origin, intersectionPoint)
			if detectDistance and curDistance > detectDistance then break end
			-- onLinePrint(planeName)
			if curDistance - minDistance < 1 then -- 数据误差纠正
				minDistance = curDistance
				resCube = cube
				resIntersectionPoint = intersectionPoint
				resPlaneName = planeName
			end
		until true
	end
	return resCube, resIntersectionPoint, resPlaneName
end

-- 点是否碰撞
--- @param pointArr table<integer, Vector>
--- @param detectDistance number
--- @return Cube|nil
function Cube:isCollision(pointArr, detectDistance)
	for _, cube in pairs(_gAllCube) do
		for _, point in pairs(pointArr) do
			if Util:distance(cube.cubeModel.centerPoint, point) > detectDistance then -- 优化, 缩减探测距离
				break
			end
			if Util:isPointInCube(point, cube.cubeModel) then
				return cube
			end
		end
	end
	return nil
end

-- 获取碰撞立方体和碰撞面
--- @param unit Unit
--- @return table<integer, table<table<integer, Cube>, table<integer, table<string, Plane>>>>
function Cube:getCollisionCubeAndPlane(unit)
	local unitPoint = Unit:getUnitCenterPoint(unit)
	local unitBottomPoint = Unit:getUnitBottomPoint(unit)
	local unitTopPoint = Unit:getUnitTopPoint(unit)
	--- @type table<integer, Cube>
	local collisionCubeArr = {} -- 碰撞立方体数组
	--- @type table<integer, table<string, Plane>>
	local collisionPlaneArr = {} -- 碰撞立方体最近面数组
	local resArr = nil
	--- @param cube Cube
	for _, cube in pairs(_gAllCube) do
		-- 选取x倍单位高度范围内的cube
		if Util:distance(cube.cubeModel.centerPoint, unitPoint) - unit.height * 2.5 <= 0.6 then
			local isPointCollision = Util:isPointInCube(unitPoint, cube.bufferCube)
			local isBottomPointCollision = Util:isPointInCube(unitTopPoint, cube.cubeModel)
			local isTopPointCollision = Util:isPointInCube(unitBottomPoint, cube.bufferCube)
			-- 获取unit到cube的最近碰撞点
			local pointToCubeMinDistance = math.maxinteger
			local toCubeMinCollisionPoint = nil
			local toCubeMinCollisionPointName = nil
			if isPointCollision then
				local distance = Util:distance(cube.cubeModel.centerPoint, unitPoint)
				if pointToCubeMinDistance > distance then
					pointToCubeMinDistance = distance
					toCubeMinCollisionPoint = unitPoint
					toCubeMinCollisionPointName = "centerPoint"
				end
			end
			if isBottomPointCollision then
				local distance = Util:distance(cube.cubeModel.centerPoint, unitTopPoint)
				if pointToCubeMinDistance > distance then
					pointToCubeMinDistance = distance
					toCubeMinCollisionPoint = unitTopPoint
					toCubeMinCollisionPointName = "bottomPoint"
				end
			end
			if isTopPointCollision then
				local distance = Util:distance(cube.cubeModel.centerPoint, unitBottomPoint)
				if pointToCubeMinDistance > distance then
					pointToCubeMinDistance = distance
					toCubeMinCollisionPoint = unitBottomPoint
					toCubeMinCollisionPointName = "topPoint"
				end
			end
			-- 获取到cube的最近面
			if toCubeMinCollisionPoint then
				local cubeModel = toCubeMinCollisionPointName == "centerPoint" and cube.cubeModel or cube.bufferCube
				local toCubeMinPlane, minDistance, minPlaneName = Util:getPointToCubeMinPlane(toCubeMinCollisionPoint, cubeModel)
				table.insert(collisionCubeArr, cube)
				table.insert(collisionPlaneArr, { name = minPlaneName, plane = toCubeMinPlane })
				resArr = { collisionCubeArr, collisionPlaneArr }
			end
		end
	end
	return resArr
end

-- 获取CubeModel的height
--- @return number
function Cube:getCubeModelHeight()
	return _gAllCube[1] and _gAllCube[1].cubeModel.height or 300 -- cube默认高300
end

return Cube
