local Spell = class()

function Spell:mirrorOwner()
  self.x, self.y, self.angle = self.owner.x, self.owner.y, self.owner.angle
end

function Spell:move(length, options)
  options = options or {}
  local x, y, angle = options.x or self.x, options.y or self.y, options.angle or self.angle
  self.x, self.y = x + math.dx(length, angle), y + math.dy(length, angle)
end

function Spell:movePlayerTo(player, x, y)
  player.x, player.y = x, y
  if player.inputs then
    table.insert(player.inputs, {
      tick = tick + 1,
      reposition = {
        x = player.x,
        y = player.y
      }
    })
  end
end

function Spell:movePlayer(player, length, options)
  options = options or {}
  local angle = options.angle or self.angle
  return Spell.movePlayerTo(self, player, player.x + math.dx(length, angle), player.y + math.dy(length, angle))
end

function Spell:moveOwnerTo(x, y)
  return Spell.movePlayerTo(self, self.owner, x, y)
end

function Spell:moveOwner(length, options)
  return Spell.movePlayer(self, self.owner, length, options)
end

function Spell:distanceTo(object, options)
  options = options or {}
  local x, y = options.x or self.x, options.y or self.y
  return math.distance(x, y, object.x, object.y)
end

function Spell:wallDistance(range)
  local x2, y2 = self.x + math.dx(range, self.angle), self.y + math.dy(range, self.angle)
  local wall, distance = ctx.collision:lineTest(self.x, self.y, x2, y2, {tag = 'wall', first = true})
  return wall and distance or range
end

function Spell:resolveCircle(x, y, r, options)
  options = options or {}
  local ox, oy = x, y
  local angle = options.angle or self.angle
  local sign = 1
  local distance = 0
  local function move() x, y = ox + math.dx(distance * sign, angle), oy + math.dy(distance * sign, angle) end
  while ctx.collision:circleTest(x, y, self.owner.radius, {tag = 'wall'}) or not math.inside(x, y, 0, 0, ctx.map.width, ctx.map.height) do
    sign = -sign
    if sign == 1 then distance = distance + 10 end
    move()
  end

  if distance > 0 or sign == -1 then
    repeat
      distance = distance - 1
      move()
    until ctx.collision:circleTest(x, y, self.owner.radius, {tag = 'wall'})

    distance = distance + 1
    move()
  end

  return x, y
end

function Spell:rot(fn)
  self.timer = self.timer - tickRate
  if self.timer <= 0 then
    f.exe(fn)
    ctx.spells:deactivate(self)
    return true
  end
end

function Spell:die()
  return ctx.spells:deactivate(self)
end

function Spell:enemiesInRadius(options)
  options = options or {}
  local x, y, r = options.x or self.x, options.y or self.y, options.radius or self.radius
  local function isEnemy(p) return p.team ~= self.owner.team end
  return ctx.collision:circleTest(x, y, r, {tag = 'player', fn = isEnemy, all = true})
end

function Spell:enemiesInLine(distance, options)
  options = options or {}
  local x, y, angle, all = options.x or self.x, options.y or self.y, options.angle or self.angle, options.all or false
  local x2, y2 = self.x + math.dx(distance, self.angle), self.y + math.dy(distance, self.angle)
  local function isEnemy(p) return p.team ~= self.owner.team end
  return select(1, ctx.collision:lineTest(x, y, x2, y2, {tag = 'player', fn = isEnemy, first = not all, all = all}))
end

function Spell:damage(enemies, amount)
  if not enemies then return end
  if enemies.id then enemies = {enemies} end
  amount = f.val(amount)

  table.each(enemies, function(enemy)
    ctx.net:emit(app.net.events.damage, {id = enemy.id, from = self.owner.id, amount = amount(enemy), tick = tick})
  end)
end

function Spell:damageInLine(distance, amount, options)
  Spell.damage(self, Spell.enemiesInLine(self, distance, options), amount)
end

function Spell:damageInRadius(amount, options)
  Spell.damage(self, Spell.enemiesInRadius(self, options), amount)
end

function Spell:lerpInit(vars)
  self._prev = {}
  if not vars then vars = {'x', 'y'} end
  for i = 1, #vars do self._prev[vars[i]] = 0 end
end

function Spell:lerpUpdate()
  table.each(self._prev, function(_, k) self._prev[k] = self[k] end)
end

function Spell:lerpGet(...)
  local res = {}
  local args = {...}
  if #args == 0 then args = {'x', 'y'} end
  table.each(args, function(x)
    table.insert(res, math.lerp(self._prev[x], self[x], tickDelta / tickRate))
  end)
  return unpack(res)
end

function Spell:drawCircle(how, options)
  options = options or {}
  love.graphics.circle(how, options.x or self.x, options.y or self.y, options.radius or self.radius)
end

function Spell:drawImage(options)
  options = options or {}
  local image = self.image or options.image
  local x, y, a, s = self.x or options.x, self.y or options.y, self.angle or options.angle, self.scale or options.scale
  local ax, ay = self.anchorx or options.anchorx, self.anchory or options.anchory
  love.graphics.draw(image, x, y, a, s, s, ax, ay)
end

function Spell:playSound(sound, options)
  options = options or {}
  options.x = options.x or self.x
  options.y = options.y or self.y
  ctx.event:emit('sound.play', table.merge({sound = sound}, options))
end

return Spell
