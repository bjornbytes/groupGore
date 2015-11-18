local Effects = class()

function Effects:init()
  self.active = love.graphics.isSupported('shader')
  self.effects = {}
  self:add('bloom')
  self:add('darkenBehind')
  self:add('motionBlur')
  self:add('deathDesaturate')
  self:add('vignette')
  self:add('antialias')
end

function Effects:update()
  if not self.active then return end
  for i = 1, #self.effects do f.exe(self.effects[i].update, self.effects[i]) end
end

function Effects:resize()
  if not self.active then return end
  for i = 1, #self.effects do f.exe(self.effects[i].resize, self.effects[i]) end
end

function Effects:add(code)
  if not self.active then return end
  local effect = new(data.effect[code])
  f.exe(effect.activate, effect)
  table.insert(self.effects, effect)
  self.effects[code] = effect
  ctx.view:register(effect, 'effect')
end

function Effects:remove(code)
  self.effects[code] = nil
  for i = #self.effects, 1, -1 do
    if self.effects[i].code == code then
      ctx.view:unregister(self.effects[i])
      table.remove(self.effects, i)
    end
  end
end

function Effects:get(code)
  return self.effects[code]
end

return Effects
