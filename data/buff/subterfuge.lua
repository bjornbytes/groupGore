local Subterfuge = {}

----------------
-- Meta
----------------
Subterfuge.name = 'Subterfuge'
Subterfuge.code = 'subterfuge'
Subterfuge.text = 'Eva is cloaked because she killed someone.'
Subterfuge.hide = false

----------------
-- Data
----------------
Subterfuge.duration = 1.5

function Subterfuge:activate()
	self.timer = Subterfuge.duration
end

function Subterfuge:update()
	self.owner.cloak = 1
	self.timer = timer.rot(self.timer, function()
		ctx.buffs:remove(self.owner, self.code)
	end)
end

function Subterfuge:stack()
	self.timer = self.duration
end

return Subterfuge