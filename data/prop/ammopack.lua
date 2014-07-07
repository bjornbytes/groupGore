local AmmoPack = {}
AmmoPack.name = 'AmmoPack'
AmmoPack.code = 'ammopack'

AmmoPack.width = 32
AmmoPack.height = 32

AmmoPack.collision = {}
AmmoPack.collision.shape = 'rectangle'
AmmoPack.collision.static = true
AmmoPack.collision.tag = 'ammopack'
AmmoPack.collision.with = {
  player = function(self, other, dx, dy)
    if not self.timer then
      self.timer = 12
      for i = 1, 5 do
        if other.slots[i].type == 'weapon' then
          f.exe(other.slots[i].ammoPack, other.slots[i], other)
        end
        if ctx.id == other.id then
          ctx.event:emit('sound.play', {sound = 'reload', x = self.x, y = self.y})
        end
      end
    end
  end
}

function AmmoPack:activate()
  self.x = self.x - (self.width / 2)
  self.y = self.y - (self.height / 2)
  ctx.event:emit('collision.attach', {object = self})
  if ctx.view then ctx.view:register(self) end
end

function AmmoPack:update()
  self.timer = timer.rot(self.timer)
  if self.timer == 0 then self.timer = false end
end

function AmmoPack:draw()
  if not self.timer then
    love.graphics.setColor(0, 150, 0, 100)
    self.shape:draw('fill')
    love.graphics.setColor(0, 150, 0, 255)
    self.shape:draw('line')
  end
end

return AmmoPack
