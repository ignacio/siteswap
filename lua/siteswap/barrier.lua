local EventEmitter = require "luanode.event_emitter"
local Class = require "luanode.class"

local Barrier = Class.InheritsFrom(EventEmitter)

function Barrier:__init(count, callback)
	local b = Class.construct(Barrier)
	
	b.count = count
	
	b.join = function()
		b.count = b.count - 1
		if b.count == 0 then
			b:emit("ready")
		end
	end
	
	if type(callback) == "function" then
		b:on("ready", callback)
	end
	
	return b
end

return Barrier
