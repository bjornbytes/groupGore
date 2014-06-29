Effects = class()

function Effects:init()
  self.active = love.graphics.isSupported('shader')
  self.effects = {}
  self:add('darkenBehind')
  self:add('motionBlur')
  self:add('deathDesaturate')
end

function Effects:update()
  if not self.active then return end
  table.with(self.effects, 'update')
end

function Effects:add(code)
  if not self.active then return end
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