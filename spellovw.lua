Spells = {}

Spells.spells = {}

function Spells:activate(owner, kind)
  local s = Spell.create()
  self.spells[#self.spells + 1] = s
  s._idx = #self.spells
  
  s.owner = type(owner) == 'number' and Players:get(owner) or owner
  s.kind = kind
  setmetatable(s, {__index = kind})
  s:activate()
  return s
end

function Spells:deactivate(s)
  f.exe(s.deactivate, s)
  table.remove(self.spells, s._idx)
end

function Spells:update()
  table.with(self.spells, f.ego('update'))
end

function Spells:draw()
  table.with(self.spells, f.ego('draw'))
end