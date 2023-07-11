
up.game:event('UI-Event', function(self, player,event)
    if event == 'back_game' then
        player:game_bad()
        return
    end
end)
