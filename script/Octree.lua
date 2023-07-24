local OctreeNode = {}
OctreeNode.__index = OctreeNode

function OctreeNode.new(min, max, minNodeSize, maxObjectsPerNode)
    local node = setmetatable({}, OctreeNode)
    node.min = min
    node.max = max
    node.minNodeSize = minNodeSize
    node.maxObjectsPerNode = maxObjectsPerNode
    node.children = nil
    node.objects = {}
    return node
end

function OctreeNode:ShouldSplit()
    return self.children == nil and (#self.objects > self.maxObjectsPerNode) and
        (self.max.x - self.min.x > self.minNodeSize)
end

function OctreeNode:Split()
    local midX = (self.min.x + self.max.x) / 2
    local midY = (self.min.y + self.max.y) / 2
    local midZ = (self.min.z + self.max.z) / 2

    local c1 = OctreeNode.new(self.min, { x = midX, y = midY, z = midZ }, self.minNodeSize, self.maxObjectsPerNode)
    local c2 = OctreeNode.new({ x = midX, y = self.min.y, z = self.min.z }, { x = self.max.x, y = midY, z = midZ },
        self.minNodeSize, self.maxObjectsPerNode)
    local c3 = OctreeNode.new({ x = self.min.x, y = midY, z = self.min.z }, { x = midX, y = self.max.y, z = midZ },
        self.minNodeSize, self.maxObjectsPerNode)
    local c4 = OctreeNode.new({ x = midX, y = midY, z = self.min.z }, { x = self.max.x, y = self.max.y, z = midZ },
        self.minNodeSize, self.maxObjectsPerNode)
    local c5 = OctreeNode.new({ x = self.min.x, y = self.min.y, z = midZ }, { x = midX, y = midY, z = self.max.z },
        self.minNodeSize, self.maxObjectsPerNode)
    local c6 = OctreeNode.new({ x = midX, y = self.min.y, z = midZ }, { x = self.max.x, y = midY, z = self.max.z },
        self.minNodeSize, self.maxObjectsPerNode)
    local c7 = OctreeNode.new({ x = self.min.x, y = midY, z = midZ }, { x = midX, y = self.max.y, z = self.max.z },
        self.minNodeSize, self.maxObjectsPerNode)
    local c8 = OctreeNode.new({ x = midX, y = midY, z = midZ }, self.max, self.minNodeSize, self.maxObjectsPerNode)

    self.children = { c1, c2, c3, c4, c5, c6, c7, c8 }

    -- 将当前节点的对象分配给子节点
    for _, object in ipairs(self.objects) do
        for _, child in ipairs(self.children) do
            if child:Intersects(object.min, object.max) then
                child:Insert(object)
            end
        end
    end

    self.objects = {} -- 清空当前节点的对象列表
end

function OctreeNode:Insert(object)
    if not self:Intersects(object.min, object.max) then
        return false
    end

    if self:ShouldSplit() then
        self:Split()
    end

    if self.children == nil then
        table.insert(self.objects, object)
    else
        for _, child in ipairs(self.children) do
            child:Insert(object)
        end
    end

    return true
end

function OctreeNode:Intersects(min, max)
    return (min.x <= self.max.x and max.x >= self.min.x) and
        (min.y <= self.max.y and max.y >= self.min.y) and
        (min.z <= self.max.z and max.z >= self.min.z)
end
