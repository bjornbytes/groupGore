local StaticGrenade = {}

StaticGrenade.code = 'staticgrenade'
StaticGrenade.duration = .8
StaticGrenade.radius = 100

function StaticGrenade:activate(mx, my)
  self.x, self.y = self.owner.x, self.owner.y
  self.hp = self.duration
  self.angle = self.owner.angle
  self.distance = math.distance(self.owner.x, self.owner.y, mx, my)
  self.speed = self.distance / self.duration
  self.tx, self.ty = self.owner.x + math.dx(self.distance, self.angle), self.owner.y + math.dy(self.distance, self.angle)

  self.z = 1
  self.zVel = 750
  self.zAcc = -1900
end

function StaticGrenade:update()
  self.x, self.y = self.x + math.dx(self.speed * tickRate, self.angle), self.y + math.dy(self.speed * tickRate, self.angle)
  self.z = self.z + self.zVel * tickRate
  self.zVel = self.zVel + self.zAcc * tickRate

  self.hp = timer.rot(self.hp, function()
    local targets = ctx.collision:circleTest(self.x, self.y, self.radius, {tag = 'player', fn = function(p) return p.team ~= self.owner.team end, all = true})
    table.each(targets, function(p)
      ctx.buffs:add(p, 'staticgrenade')
      ctx.buffs:remove(p, 'plasmasickness')
    end)
    ctx.event:emit('particle.create', {
      kind = 'staticgrenade',
      vars = {
        x = self.x,
        y = self.y,
        radius = self.radius
      }
    })
    ctx.spells:deactivate(self)
  end)
end

function StaticGrenade:draw()
  local x, y = ctx.view:three(self.x, self.y, self.z)
  local scale = 1 + (ctx.view:convertZ(self.z) / 500)
  local g = love.graphics
  g.setColor(0, 255, 255)
  g.circle('fill', x, y, 10 * scale)
end

return StaticGrenade
