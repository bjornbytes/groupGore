local Rage = {}

----------------
-- Meta
----------------
Rage.name = 'Rage'
Rage.code = 'rage'
Rage.text = 'The Brute gains 20% lifesteal when below 50% health.'
Rage.type = 'passive'


----------------
-- Behavior
----------------
function Rage:activate(owner)
  --
end

function Rage:update(owner)
  if owner.health < owner.maxHealth * .5 then
    if not ctx.buffs:get(owner, 'rage') then
      ctx.buffs:add(owner, 'rage')
    end
  else
    ctx.buffs:remove(owner, 'rage')
  end
end

return Rage
