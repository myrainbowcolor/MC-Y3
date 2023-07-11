
local mt = {}
setmetatable(_G, mt)

function mt:__index(k)
	if k == 'undef' then
		return nil
	else
		print(('Read a non-existent global variable[%s]'):format(k))
		log.error(('Read a non-existent global variable[%s]'):format(k))
		return nil
	end
end

function mt:__newindex(k, v)
	if k == 'undef' then
		print('cannot change undef 。')
		log.error('cannot change undef 。')
	else
		print(('save global variable[%s][%s]'):format(k, v))
		log.error(('save global variable[%s][%s]'):format(k, v))
		rawset(self, k, v)
	end
end
