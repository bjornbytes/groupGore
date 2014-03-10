Spells = class()

function Spells:init()
  self.spells = {}
  self.depth = -100
  if self.overwatch.view then self.overwatch.view:register(self) end
end

function Spells:activate(owner, kind)
  local s = Spell.create()
  self.spells[#self.spells + 1] = s
  s._idx = #self.spells
  
  s.owner = type(owner) == 'number' and ovw.players:get(owner) or owner
  s.kind = type(kind) == 'number' and data.spell[kind] or kind
  setmetatable(s, {__index = s.kind})
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
  table.with(self.spells, 'draw', true)
end