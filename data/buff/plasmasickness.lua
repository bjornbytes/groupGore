local PlasmaSickness = {}

PlasmaSickness.name = 'PlasmaSickness'
PlasmaSickness.code = 'plasmasickness'
PlasmaSickness.text = 'This unit is slowed.'
PlasmaSickness.hide = false

PlasmaSickness.duration = 6

function PlasmaSickness:activate()
	self.stacks = self.stacks or 1
	self.amount = self.owner.class.speed * .05 * self.stacks
	self.owner.haste = self.owner.haste - self.amount
	self.timer = self.duration
end

function PlasmaSickness:deactivate()
	self.owner.haste = self.owner.haste + self.amount
end

function PlasmaSickness:update()
	self.timer = timer.rot(self.timer, function()
		ctx.buffs:remove(self.owner, 'plasmasickness')
	end)
end

function PlasmaSickness:stack()
	self:deactivate()
	self.stacks = math.min(self.stacks + 1, 3)
	self:activate()
end

return PlasmaSickness
