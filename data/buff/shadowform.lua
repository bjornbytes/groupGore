local Shadowform = {}

Shadowform.name = 'Shadowform'
Shadowform.code = 'shadowform'
Shadowform.text = 'Eva is more dangerous but more vulnerable.'

function Shadowform:activate()
  self.depth = 4
  if ctx.view then ctx.view:register(self) end
end

function Shadowform:deactivate()
  if ctx.view then ctx.view:unregister(self) end
end

function Shadowform:draw()
  love.graphics.setColor(0, 0, 0, 100)
  local x, y = self.owner:drawPosition()
  love.graphics.circle('fill', x, y, 26)
end

return Shadowform
