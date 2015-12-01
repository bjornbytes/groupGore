local Bloodlust = {}

----------------
-- Meta
----------------
Bloodlust.name = 'Bloodlust'
Bloodlust.code = 'bloodlust'
Bloodlust.text = 'It is Bloodlust.  My wife for hire.'
Bloodlust.type = 'passive'


----------------
-- Behavior
----------------
function Bloodlust:activate(owner)
  ctx.event:on(app.net.events.dead, function(data)
    if data.kill == owner.id and data.id ~= owner.id then
      ctx.buffs:add(owner, 'bloodlust')
    end
  end, self)
end

function Bloodlust:deactivate(owner)
  ctx.event:remove(app.net.events.dead, self)
end

function Bloodlust:value(owner)
  local buff = ctx.buffs:get(owner, 'bloodlust')
  if buff then return buff.timer / buff.duration end
  return 0
end

return Bloodlust
