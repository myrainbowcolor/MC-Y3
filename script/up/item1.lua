-- 先写行注释冷静一下——ddt
--基础属性
local mt = {}
mt.__index = mt
mt.type = "item"
mt.id = nil
up.item = mt

--声明事件
local event_name = 
{
    
}
--注册事件
function item_event_init(item,id)
    
    for k, v in pairs(event_name) do            --遍历所有预设事件
        if item[k] then                         --如果物品有该事件就啥都不做
        else
            up.print('写入事件')
            local trg = New_item_trigger(id, v[1], v[3], v[2], true)           --没对应事件就给他注册一个        
            
            function trg.on_event(trigger, event, actor, data)                                        --该事件被触发时发信号
                    local tbl = {}                                                 --记录事件中的参数
                    if v[4] then
                        for a,b in pairs(v[4]) do                           
                            table.insert(tbl,data[b])                                                 
                        end
                    end            
                up.game:event_notify(v[3], table.unpack(tbl))
            end
        end
    end
end

function up.setitem(i)
    local id = i:get_key()
    local item = {}
    item._base = i
    item[id]={}   
    item_event_init(item[id],id)
    setmetatable(item,mt)
    up.print('创建物品')
    return item
end

--执行：
--创建物品在目标点 item实例 checked
function up.item.CreateItem(point,item_key,Role)
    local TargetItem = gameapi.create_item(point._base,item_key,Role)
    local id = TargetItem:get_key()
    return  up.setitem(TargetItem)
end

--删除物品（触发器生效）checked
function up.item:SelfDestruct()
    up.game:event_notify("delete item",self._base:get_name()) --丢删除物品事件
    self._base:api_remove()
end

--获取物品id int checked
function up.item:Id()
    return self._base.api_get_key()
end

--获取物品名称 string checked
function up.item:Name()
    return self._base:get_name()
end
--获取物品类型 int checked
function up.item:Type()
    return self._base:api_get_type()
end
--获取物品等级 int checked
function up.item:Level()
    return self._base:api_get_level()
end
--获取物品持有者 role实例 checked
function up.item:OwnerRole()
    return self._base:api_get_owner()
end
--物品移除键值对
function up.item:RemoveKV(string)
    self._base:api_remove_kv(string)
end
--设置物品可否被出售  checked
function up.item:CanBeSold(bool)
    self._base:api_set_sale_state(bool)
end

--删除物品（触发器不生效）
-- function up.item:SelfDestruct(bool)
--     self._base:api_delete()
-- end

--物品是否在场景中 bool checked
function up.item:IsInScene()
    return self._base:api_is_in_scene()
end
--物品所在位置 point
function up.item:GetLocation()
    return self._base:api_get_position()
end
--获取拥有该物品的单位 unit实例 checked
function up.item:GetOwner()
    return self._base:api_get_owner()
end
--获取拥有该物品的玩家 role实例
function up.item:GetCreator()
    return self._base:api_get_creator()
end




