local hardon = require 'lib/hardon'

Collision = class()

local cellSize = 128

function Collision:init()
  self.hc = hardon(cellSize, function(_, a, b, dx, dy)
    if self.players[a] and self.players[b] then
      a:move(dx / 2, dy / 2)
      b:move(-dx / 2, -dy / 2)
      local p
      p = self.playerShadows[self.players[a]] or ovw.players:get(self.players[a])
      p.x, p.y = p.x + dx / 2, p.y + dy / 2
      p = self.playerShadows[self.players[b]] or ovw.players:get(self.players[b])
      p.x, p.y = p.x - dx / 2, p.y - dy / 2
    elseif self.players[a] and not self.players[b] then
      a:move(dx, dy)
      local p = self.playerShadows[self.players[a]] or ovw.players:get(self.players[a])
      p.x, p.y = p.x + dx, p.y + dy
    elseif not self.players[a] and self.players[b] then
      b:move(-dx, -dy)
      local p = self.playerShadows[self.players[b]] or ovw.players:get(self.players[b])
      p.x, p.y = p.x - dx, p.y - dy
    else      
      a:move(dx / 2, dy / 2)
      b:move(-dx / 2, -dy / 2)
    end
  end)
  
  ovw.event:on('player.activate', function(data)
    self:register(ovw.players:get(data.id))
  end)
  
  ovw.event:on('player.deactivate', function(data)
    self.hc:remove(ovw.players:get(data.id).shape)
  end)

  ovw.event:on(evtClass, function(data)
    self.hc:addToGroup('players' .. data.team, ovw.players:get(data.id).shape)
  end)
  
  ovw.event:on('prop.create', function(data) self:register(data.prop) end)

  ovw.event:on('prop.move', function(data)
    if data.prop.collision.shape == 'rectangle' then
      data.prop.shape:moveTo(data.prop.x + data.prop.width / 2, data.prop.y + data.prop.height / 2)
    else
      data.prop.shape:moveTo(data.x, data.y)
    end
  end)

  ovw.event:on('prop.scale', function(data)
    self.hc:remove(data.prop.shape)
    self:register(data.prop)
  end)

  ovw.event:on('player.move', function(data)
    data.player.shape:moveTo(data.x, data.y)
  end)
end

function Collision:update()
  self.hc:update(tickRate)
end

function Collision:register(obj)
  assert(obj.collision)
  local shape
  if obj.collision.shape == 'rectangle' then
    shape = self.hc:addRectangle(obj.x, obj.y, obj.width, obj.height)
  elseif obj.collision.shape == 'circle' then
    shape = self.hc:addCircle(obj.x, obj.y, obj.radius)
  end

  if obj.collision.solid then
    shape:setPassive()
  end

  obj.shape = shape
  shape.owner = obj
end

function Collision:wallRaycast(x, y, dir, distance)
  local dx, dy = math.cos(dir), math.sin(dir)
  local shapes = {}
  local distances = {}
  
  for _, prop in pairs(ovw.map.propsBy.wall) do
    local shape = prop.shape
    local hit, dis = shape:intersectsRay(x, y, dx, dy)
    if hit and dis <= distance and dis >= 0 then
      shapes[#shapes + 1] = shape
      distances[shape] = dis
    end
  end
  
  table.sort(shapes, function(a, b) return distances[a] < distances[b] end)
  
  local res
  if shapes[1] then
    res = {wall = shapes[1], distance = distances[shapes[1]]}
  end
  
  return res
end

function Collision:playerRaycast(x, y, dir, options)
  local dx, dy = math.cos(dir), math.sin(dir)
  local maxdis, team, sort, all = options.distance, options.team, options.sort, options.all
  local res = {}
  
  for i = 1, 16 do
    local p = ovw.players:get(i)
    local shape = p.shape
    if shape and (not team or p.team == team) then
      local shape = self.players[i]
      local hit, dis = shape:intersectsRay(x, y, dx, dy)
      if hit and dis <= maxdis or math.huge and dis >= 0 then
        res[#res + 1] = {player = p, shape = shape, distance = dis}
        if not all and not sort then break end
      end
    end
  end
  
  if sort then table.sort(res, function(a, b) return a.distance < b.distance end) end
  
  return all and res or res[1]
end
