Effects = class()

function Effects:init()
  self.effects = {}
  self:add('motionBlur')
end

function Effects:update()
  table.with(self.effects, 'update')
end

function Effects:add(code)
  local effect = new(data.effect[code])
  f.exe(effect.activate, effect)
  table.insert(self.effects, effect)
  ctx.view:register(effect, 'effect')
end

function Effects:remove(code)
  for i = #self.effects, 1, -1 do
    if self.effects[i].code == code then
      ctx.view:unregister(self.effects[i])
      table.remove(self.effects, i)
    end
  end
end