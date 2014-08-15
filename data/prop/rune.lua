local Rune = {}
Rune.name = 'Rune'
Rune.code = 'rune'

Rune.width = 32
Rune.height = 32
Rune.effects = {'refillAmmo', 'refillHealth', 'speedBoost'}

Rune.collision = {}
Rune.collision.shape = 'rectangle'
Rune.collision.static = true
Rune.collision.tag = 'rune'
Rune.collision.with = {
  player = function(self, other, dx, dy)
    if not self.timer and not other.ghosting then
      self.timer = 12
      self[self.effect](self, other)
      self:setEffect()
    end
  end
}

function Rune:activate()
  self.x = self.x - (self.width / 2)
  self.y = self.y - (self.height / 2)
  ctx.event:emit('collision.attach', {object = self})
  self.iterations = (self.x + self.y) / 2
  self:setEffect()
  if ctx.view then ctx.view:register(self) end
end

function Rune:update()
  self.timer = timer.rot(self.timer)
  if self.timer == 0 then self.timer = false end
end

function Rune:draw()
  if not self.timer then
    if self.effect == 'refillAmmo' then love.graphics.setColor(0, 150, 0, 100)
    elseif self.effect == 'refillHealth' then love.graphics.setColor(150, 0, 0, 100)
    elseif self.effect == 'speedBoost' then love.graphics.setColor(0, 0, 150, 100) end
    self.shape:draw('fill')
    if self.effect == 'refillAmmo' then love.graphics.setColor(0, 150, 0, 255)
    elseif self.effect == 'refillHealth' then love.graphics.setColor(150, 0, 0, 255)
    elseif self.effect == 'speedBoost' then love.graphics.setColor(0, 0, 150, 255) end
    self.shape:draw('line')

    if ctx.effects and ctx.effects:get('bloom') then
      ctx.effects:get('bloom'):render(function()
        if self.effect == 'refillAmmo' then love.graphics.setColor(100, 255, 100, 255)
        elseif self.effect == 'refillHealth' then love.graphics.setColor(255, 100, 100, 255)
        elseif self.effect == 'speedBoost' then love.graphics.setColor(100, 100, 255, 255) end
        love.graphics.rectangle('fill', self.x - 16, self.y - 16, self.width + 32, self.height + 32)
      end)
    end
  end
end

function Rune:setEffect()
  local l, h = love.math.getRandomSeed()
  love.math.setRandomSeed(math.floor(100000000 * love.math.noise(1111111 * self.iterations)), math.floor(100000000 * love.math.noise(self.x * self.iterations, self.y - self.iterations)))
  self.iterations = self.iterations + 1
  self.effect = self.effects[love.math.random(1, #self.effects)]
  love.math.setRandomSeed(l, h)
end

function Rune:refillAmmo(player)
  for i = 1, 5 do
    if player.slots[i].type == 'weapon' then
      f.exe(player.slots[i].refillAmmo, player.slots[i], player)
    end
    if ctx.id == player.id then
      ctx.event:emit('sound.play', {sound = 'reload', x = self.x, y = self.y})
      ctx.event:emit('particle.create', {
        kind = 'arcadetext',
        vars = {
          x = player.x,
          y = player.y,
          str = '+ammo'
        }
      })
    end
  end
end

function Rune:refillHealth(player)
  player.health = math.min(player.health + (player.maxHealth / 4), player.maxHealth)
  if ctx.id == player.id then
    ctx.event:emit('sound.play', {sound = 'reload', x = self.x, y = self.y})
    ctx.event:emit('particle.create', {
      kind = 'arcadetext',
      vars = {
        x = player.x,
        y = player.y,
        str = '+health'
      }
    })
  end
end

function Rune:speedBoost(player)
  ctx.buffs:add(player, 'runespeedboost')
  if ctx.id == player.id then
    ctx.event:emit('sound.play', {sound = 'reload', x = self.x, y = self.y})
    ctx.event:emit('particle.create', {
      kind = 'arcadetext',
      vars = {
        x = player.x,
        y = player.y,
        str = '+speed'
      }
    })
  end
end

return Rune
