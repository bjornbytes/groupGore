Spells = class()

function Spells:init()
  self.spells = {}
  self.depth = -100
  if ovw.view then ovw.view:register(self) end
end

function Spells:activate(owner, kind)
  local s = new(kind)
  s.owner = ovw.players:get(owner)
  self.spells[#self.spells + 1] = s
  s._idx = #self.spells
  s:activate()
  return s
end

function Spells:deactivate(s)
  f.exe(s.deactivate, s)
  table.remove(self.spells, s._idx)
end

function Spells:update()
  table.with(self.spells, 'update')
end

function Spells:draw()
  table.with(self.spells, 'draw')
end
