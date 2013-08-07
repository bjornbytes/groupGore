Spells = {}

Spells.spells = {}
Spells.active = {}
Spells.next = {17, 33, 49, 65, 81, 97, 113, 129, 145, 161, 177, 193, 209, 225, 241}

function Spells:activate(owner, kind)
  local s = self:get(self.next[owner])
  assert(not s.active)
  s.active = true
  s.owner = Players:get(owner)
  setmetatable(s, {__index = kind})
  s:activate()
  self:refresh()
  return s.id
end

function Spells:deactivate(id)
  local s = self:get(id)
  assert(s.active)
  s.active = false
  f.exe(s.deactivate, s)
  self:refresh()
end

function Spells:get(id)
  return self.spells[id]
end

function Spells:with(sel, fn)
  if type(sel) == 'number' then
    fn(self:get(sel))
  elseif type(sel) == 'table' then
    for _, id in ipairs(sel) do
      fn(self:get(id))
    end
  elseif type(sel) == 'function' then
    for _, s in ipairs(table.filter(self.spells, sel)) do
      fn(s)
    end
  end
end

function Spells:update()
  self:with(self.active, f.ego('update'))
end

function Spells:draw()
  self:with(self.active, f.ego('draw'))
end

function Spells:refresh()
  for i = 1, 16 do self.next[i] = nil end
  for i = 17, 256 do
    self.active[i - 16] = nil
    if self.spells[i].active then table.insert(self.active, i)
    else
      local idx = math.floor((i - 1) / 16)
      self.next[idx] = self.next[idx] or i
    end
  end
end

for i = 17, 256 do
  Spells.spells[i] = Spell:create()
  Spells.spells[i].id = i
  Spells.spells[i].owner = math.floor((i - 1) / 16)
end