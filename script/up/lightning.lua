local setmetatable = setmetatable

local mt = {}
mt.__index = mt
mt.type = 'lightning'
mt.show = true

function mt:remove()
    GameAPI.remove_link_sfx(self.light)
end

function mt:is_show()
    return self.show
end

function mt:show(show)
    self.show = show
    GameAPI.enable_link_sfx_show(self.light,show)
end

function mt:set(data)
    local LinkSfxPointType = {
        ['start'] = 1,
        ['end'] = 2,
    }
    if data.target.type == 'point' then
        GameAPI.set_link_sfx_point(self.light,LinkSfxPointType[data.point_type],data.target._base,data.height)
    end
    if data.target.type == 'unit' then
        GameAPI.set_link_sfx_unit_socket(self.light,LinkSfxPointType[data.point_type],data.target._base,data.socket)
    end
end

up.lightning = function(data)
    local lightning = {}
    --Determine which way to create
    if not data.source_height then
        data.source_height = Fix32(0)
    else
        data.source_height = Fix32(data.source_height)
    end
    if not data.target_height then
        data.target_height = Fix32(0)
    else
        data.target_height = Fix32(data.target_height)
    end
    if data.source.type == 'unit' and data.target.type == 'point' then
        lightning.light = GameAPI.create_link_sfx_from_unit_to_point(data.id,data.source,data.source_socket,data.target._base,data.target_height)
    elseif data.source.type == 'unit' and data.target.type == 'unit' then
        lightning.light = GameAPI.create_link_sfx_from_unit_to_unit(data.id,data.source,data.source_socket,data.target,data.target_socket)
    elseif data.source.type == 'point' and data.target.type == 'unit' then
        lightning.light = GameAPI.create_link_sfx_from_point_to_unit(data.id,data.source._base,data.source_height,data.target,data.target_socket)
    elseif data.source.type == 'point' and data.target.type == 'point' then
        lightning.light = GameAPI.create_link_sfx_from_point_to_point(data.id,data.source._base,data.source_height,data.target._base,data.target_height)
    else
        up.print('Lightning effect creation that does not meet the requirements')
    end

    --GameAPI.print_to_dialog(3,'create','lightning','')

    setmetatable(lightning, mt)
    return lightning
end

--for debug
--up.wait(1,function()
--    local light = up.lightning{
--        id = 1020390114,
--        source = up.point(0,0,0),
--        source_height = 100,
--        target = up.point(100,100,0),
--        target_height = 0,
--    }
--    local x = 0
--    local y = 0
--    up.loop(0.03,function()
--        x = x + 1
--        light:set{
--            point_type = 'start',
--            target = up.point(x,0,0),
--            height = 100,
--        }
--    end)
--    up.wait(3,function()
--        light:show(false)
--    end)
--end)
