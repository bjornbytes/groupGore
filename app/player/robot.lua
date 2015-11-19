local PlayerRobot = extend(app.player.server)

function PlayerRobot:activate()
  app.playerServer.activate(self)

  self.username = 'robot'

  self.state = 'navigating'

  self.dirTimer = 0
  self.direction = 0
  self.directionOffset = 0
  self.w, self.a, self.s, self.d = false, false, false, false
  self.mx, self.my, self.ml = 0, 0, false
  self.backwards = love.math.random() * 2 * math.pi
  self.checkBehind = 5 + love.math.random(3)
  self.sleep = love.math.random() * 2

  self.target = nil
end

function PlayerRobot:logic()
  self.sleep = timer.rot(self.sleep)
  if self.sleep > 0 then return end

  self.checkBehind = timer.rot(self.checkBehind)
  if self.checkBehind == 0 then self.checkBehind = 5 + love.math.random(3) end

  if self.state == 'navigating' then
    self.dirTimer = timer.rot(self.dirTimer)
    if self.dirTimer == 0 then
      local directions = {}
      for i = math.pi / 4, math.pi * 2, math.pi / 4 do
        table.insert(directions, {i, self:rateDirection(i)})
      end
      table.sort(directions, function(a, b) return a[2] > b[2] end)
      local entry = directions[1]
      if entry[1] == 2 * math.pi then entry[1] = 0 end
      local dx = math.cos(entry[1])
      if math.abs(dx) < .5 then dx = 0 end
      local dy = math.sin(entry[1])
      if math.abs(dy) < .5 then dy = 0 end
      self.direction = entry[1]
      self.w = dy < 0
      self.a = dx < 0
      self.s = dy > 0
      self.d = dx > 0
      self.dirTimer = 1 + love.math.random() * 1
      self.backwards = math.pi + entry[1]
    end

    local sign = 1
    if self.checkBehind < .3 then sign = -1 end
    self.directionOffset = --[[self.directionOffset + ]](love.math.noise(tick / 200 + self.id) * 2 - 1) * math.pi
    self.mx = math.lerp(self.mx, self.x + math.dx(100 * sign, self.direction + self.directionOffset), math.min(4 * tickRate, 1))
    self.my = math.lerp(self.my, self.y + math.dy(100 * sign, self.direction + self.directionOffset), math.min(4 * tickRate, 1))
    self.ml = false

    ctx.players:each(function(p)
      if p.team == self.team then return end
      if math.distance(p.x, p.y, self.x, self.y) > 800 then return end
      if math.abs(math.anglediff(self.angle, math.direction(self.x, self.y, p.x, p.y))) > math.pi / 2 then return end
      if ctx.collision:lineTest(self.x, self.y, p.x, p.y, {tag = 'wall'}) then return end
      --self.state = 'combat'
      self.target = p
    end)
  elseif self.state == 'combat' then
    self.mx = self.target.x
    self.my = self.target.y
    self.ml = true
    if self.target.ded then
      self.state = 'navigating'
    end
  end

  self:trace({
    tick = tick,
    w = self.w,
    a = self.a,
    s = self.s,
    d = self.d,
    x = self.mx,
    y = self.my,
    l = self.ml
  }, 0)
end

function PlayerRobot:rateDirection(dir)
  local visionRadius = 1000
  local tooClose = 250
  local hit, d = ctx.collision:lineTest(self.x, self.y, self.x + math.dx(visionRadius, dir), self.y + math.dy(visionRadius, dir), {tag = 'wall', first = true})
  local hit2, d2 = ctx.collision:lineTest(self.x, self.y, self.x + math.dx(visionRadius, dir), self.y + math.dy(visionRadius,dir), {tag = 'teamwall', fn = function(w) return w.team ~= self.team end, first = true})
  if not hit and hit2 then d = d2 end
  if hit and hit2 and d2 < d then d = d2 end
  local distanceScore = ((hit and d or visionRadius) / visionRadius)
  local directionScore = math.abs(math.anglediff(dir, self.backwards or dir)) / math.pi
  score = distanceScore * .6 + directionScore * .4
  score = score - .2 + love.math.random() * .4
  if d <= tooClose then distanceScore = distanceScore - (.1 + (1 - (d / tooClose))) end
  score = math.clamp(score, 0, 1)
  return score
end

return PlayerRobot
