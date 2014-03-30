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
  
  self.players = {}
  self.playerShadows = {}
  
  ovw.event:on(evtClass, function(data)
    local shape = self.hc:addCircle(0, 0, gg.class[data.class].size)
    self.players[data.id] = shape
    self.hc:addToGroup(data.team, shape)
    self.players[shape] = data.id
  end)
  
  ovw.event:on(evtLeave, function(data)
    self.hc:remove(self.players[data.id])
    self.players[self.players[data.id]] = nil
    self.players[data.id] = nil
  end)
end

function Collision:update()
  for i = 1, 16 do
    if self.players[i] then
      local p = ovw.players:get(i)
      self.players[i]:moveTo(p.x, p.y)
    end
  end
  
  self.hc:update(tickRate)
end

function Collision:updateClone(id, obj)
  self.playerShadows[id] = obj
  self.players[id]:moveTo(obj.x, obj.y)
  self.hc:update(tickRate)
  self.playerShadows[id] = nil
end

function Collision:register(obj)
  if not obj.shape then
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
    local shape = self.players[i]
    local p = ovw.players:get(i)
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
