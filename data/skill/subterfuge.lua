local Subterfuge = {}

Subterfuge.name = 'Subterfuge'
Subterfuge.code = 'subterfuge'
Subterfuge.text = 'When you get a kill you cloak.'
Subterfuge.type = 'passive'

function Subterfuge:activate(owner)
	ctx.event:on(evtDead, function(data)
		if data.kill == owner.id then
			ctx.buffs:add(owner, 'subterfuge')
		end
	end, self)
end

function Subterfuge:deactivate(owner)
  ctx.event:remove(evtDead, self)
end

function Subterfuge:value(owner)
  local buff = ctx.buffs:get(owner, 'subterfuge')
  if buff then return buff.timer / buff.duration end
  return 0
end

return Subterfuge