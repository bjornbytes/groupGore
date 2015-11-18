local Spells = class()

function Spells:init()
  self.spells = {}
  self.depth = -100
  if ctx.view then ctx.view:register(self) end
end

function Spells:activate(owner, kind, ...)
  local s = new(kind)
  s.owner = ctx.players:get(owner)
  self.spells[s] = s
  s:activate(...)
  return s
end

function Spells:deactivate(s)
  f.exe(s.deactivate, s)
  self.spells[s] = nil
end

function Spells:update()
  table.with(self.spells, 'update')
end

function Spells:draw()
  table.with(self.spells, 'draw')
end

return Spells
