local hardon = require 'lib/hardon'

Collision = class()

local cellSize = 128

function Collision:init()
  self.hc = hardon(cellSize, function(_, a, b, dx, dy)
    a, b = a.owner, b.owner
    local function isPlayer(t) return t.class and t.team end
    if isPlayer(a) then
      a.shape:move(dx, dy)
      a.x, a.y = a.x + dx, a.y + dy
    elseif isPlayer(b) then
      b.shape:move(-dx, -dy)
      b.x, b.y = b.x - dx, b.y - dy
    else
      --
    end
  end)
  
  ovw.event:on('player.deactivate', function(data)
    self.hc:remove(ovw.players:get(data.id).shape)
  end)

  ovw.event:on(evtClass, function(data)
    local p = ovw.players:get(data.id)
    if not p.shape then self:register(p) end
    self.hc:removeFromGroup('players' .. (1 - data.team), p.shape)
    self.hc:addToGroup('players' .. data.team, p.shape)
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
end

function Collision:update()
  for i = 1, 16 do
    local p = ovw.players:get(i)
    if p.shape then
      p.shape:moveTo(p.x, p.y)
    end
  end
  
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
    if shape and ((not team) or p.team == team) then
      local hit, dis = shape:intersectsRay(x, y, dx, dy)
      if hit and dis <= (maxdis or math.huge) and dis >= 0 then
        res[#res + 1] = {player = p, shape = shape, distance = dis}
        if (not all) and (not sort) then break end
      end
    end
  end
  
  if sort then table.sort(res, function(a, b) return a.distance < b.distance end) end
  
  return all and res or res[1]
end
