local Cart = require 'data/prop/cart'
local CartServer = extend(Cart)
CartServer.code = 'cartServer'

function CartServer:activate(map)
  Cart.activate(self, map)

  self.points = {}
  for i = 1, #self.curves do
    local t = self.curves[i]:render(3)
    local a, b = 3, #t - 2
    if i == 1 then a = 1 end
    if i == #self.curves then b = #t end
    for j = a, b do
      table.insert(self.points, t[j])
    end
  end
  for i = 1, #self.points, 2 do
    if self.points[i] == self.x and self.points[i + 1] == self.y then
      self.index = i
      break
    end
  end
  self.speed = 0
end

function CartServer:update()
  Cart.update(self)

  local players = {[purple] = 0, [orange] = 0}
  ctx.players:each(function(player)
    if math.distance(self.x, self.y, player.x, player.y) < self.range then
      players[player.team] = players[player.team] + 1
    end
  end)

  if (players[purple] == 0 and players[orange] == 0) or (players[purple] > 0 and players[orange] > 0) then
    self.speed = math.lerp(self.speed, 0, 4 * tickRate)
  elseif players[purple] > 0 then
    self.speed = math.lerp(self.speed, Cart.speed * players[purple], 4 * tickRate)
  else
    self.speed = math.lerp(self.speed, -Cart.speed * players[orange], 4 * tickRate)
  end

  if self.speed ~= 0 then
    local dis = math.abs(self.speed * tickRate)
    local sign = math.sign(self.speed)
    while dis > 0 and self.index + sign > 1 and self.index + sign < #self.points do
      local nx, ny = self.points[self.index + (2 * sign)], self.points[self.index + (2 * sign) + 1]
      local d = math.distance(self.x, self.y, nx, ny)
      if d < dis then
        self.index = self.index + (2 * sign)
        self.x = nx
        self.y = ny
        dis = dis - d
      else
        local dir = math.direction(self.x, self.y, nx, ny)
        self.x = self.x + math.dx(dis, dir)
        self.y = self.y + math.dy(dis, dir)
        dis = 0
        break
      end
    end

    if self.index + sign <= 1 or self.index + sign >= #self.points then self.speed = 0 end

    if self.index == 1 then
      ctx.map:modExec('scoring', 'win', orange)
    elseif self.index == #self.points - 1 then
      ctx.map:modExec('scoring', 'win', purple)
    end

    ctx.net:emit(evtProp, {id = self.id, x = math.round(self.x * 10), y = math.round(self.y * 10)})
  end
end

return CartServer
