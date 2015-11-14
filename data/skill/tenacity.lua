local Tenacity = {}

----------------
-- Meta
----------------
Tenacity.name = 'Tenacity'
Tenacity.code = 'tenacity'
Tenacity.text = 'Wrexx gains lifesteal based on missing health.'
Tenacity.type = 'passive'


----------------
-- Behavior
----------------
function Tenacity:activate(owner)
  --
end

function Tenacity:update(owner)
  local enemies = 0
  ctx.players:each(function(p)
    if p.team ~= owner.team and math.distance(p.x, p.y, owner.x, owner.y) < 300 then
      enemies = enemies + 1
    end
  end)

  local buff = ctx.buffs:get(owner, 'tenacity')
  if not buff and enemies == 0 then return end

  if not buff then
    buff = ctx.buffs:add(owner, 'tenacity')
  end

  if enemies > buff.stacks then
    for i = 1, enemies - buff.stacks do
      ctx.buffs:add(owner, 'tenacity')
    end
  elseif enemies < buff.stacks then
    for i = 1, buff.stacks - enemies do
      ctx.buffs:remove(owner, 'tenacity', true)
    end
  end
end

return Tenacity
