local Tenacity = {}

----------------
-- Meta
----------------
Tenacity.name = 'Tenacity'
Tenacity.code = 'tenacity'
Tenacity.text = 'Wrexx gains lifesteal for every nearby enemy.'
Tenacity.hide = false


----------------
-- Data
----------------
function Tenacity:activate()
  self.stacks = 0
end

function Tenacity:deactivate()
  self.owner.lifesteal = self.owner.lifesteal - (.15 * self.stacks)
end

function Tenacity:stack()
  self.owner.lifesteal = self.owner.lifesteal + .15
  self.stacks = self.stacks + 1
end

function Tenacity:unstack()
  self.owner.lifesteal = self.owner.lifesteal - .15
  self.stacks = self.stacks - 1
  if self.stacks == 0 then ctx.buffs:remove(self.owner, 'tenacity') end
end

return Tenacity
