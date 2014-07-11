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
  self.depth = -10000
  if ctx.view then ctx.view:register(self) end
end

function PlasmaSickness:deactivate()
	self.owner.haste = self.owner.haste + self.amount
  if ctx.view then ctx.view:unregister(self) end
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

function PlasmaSickness:draw()
  local ox, oy = self.owner.drawX, self.owner.drawY - 120
  local dir = math.pi / 2
  for i = 1, self.stacks do
    local x1, y1 = ox + math.dx(10, dir), oy + math.dy(10, dir)
    local x2, y2 = x1 + math.dx(10, dir - .5), y1 + math.dy(10, dir - .5)
    local x3, y3 = x1 + math.dx(10, dir + .5), y1 + math.dy(10, dir + .5)
    love.graphics.setColor(0, 255, 255, 100 * self.owner.alpha)
    love.graphics.polygon('fill', x1, y1, x2, y2, x3, y3)
    love.graphics.setColor(0, 255, 255, 255 * self.owner.alpha)
    love.graphics.polygon('line', x1, y1, x2, y2, x3, y3)
    dir = dir + (2 * math.pi / 3)
  end
end

return PlasmaSickness
