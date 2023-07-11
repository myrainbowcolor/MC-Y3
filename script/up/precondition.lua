
up.game:event('Item-RreconditionFailed', function(_,_itemno,player)
    player.item_percondition_cache[_itemno] = false
end)

up.game:event('Item-RreconditionSucceed', function(_,_itemno,player)
    player.item_percondition_cache[_itemno] = true
end)

up.game:event('Tech-RreconditionFailed', function(_,_techno,player)
    player.tech_percondition_cache[_techno] = false
end)

up.game:event('Tech-RreconditionSucceed', function(_,_techno,player)
    player.tech_percondition_cache[_techno] = true
end)

up.game:event('Player-TechChange',function(_,_techno,player)
    player.tech_percondition_cache[_techno] = nil
end)
