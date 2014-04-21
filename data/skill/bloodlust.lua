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
function Bloodlust.activate(self, bloodlust)
  ctx.event:on(evtDead, function(data)
    if data.kill == self.id and data.id ~= self.id then
      ctx.buffs:add(self, 'bloodlust')
    end
  end)
end

function Bloodlust.value(self, bloodlust)
  local buff = ctx.buffs:get(self, 'bloodlust')
  if buff then
    return buff.timer / buff.duration
  end
  return 0
end

return Bloodlust
