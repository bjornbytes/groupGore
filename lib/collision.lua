local hardon = require 'lib/hardon'

Collision = class()
Collision.cellSize = 128

function Collision:init()
  local function onCollide(dt, a, b, dx, dy)
    a, b = a.owner, b.owner
    f.exe(a.collision.with and a.collision.with[b.collision.tag], a, b, dx, dy)
    f.exe(b.collision.with and b.collision.with[a.collision.tag], b, a, -dx, -dy)
  end
  
  self.hc = hardon(self.cellSize, onCollide)

  ctx.event:on('prop.create', function(data) self:register(data.prop) end)
  ctx.event:on('prop.move', function(data)
    if data.prop.collision.shape == 'rectangle' then
      data.prop.shape:moveTo(data.prop.x + data.prop.width / 2, data.prop.y + data.prop.height / 2)
    else
      data.prop.shape:moveTo(data.x, data.y)
    end
  end)
  ctx.event:on('prop.scale', function(data)
    self.hc:remove(data.prop.shape)
    self:register(data.prop)
  end)
end

function Collision:update()
  for i = 1, 16 do
    local p = ctx.players:get(i)
    if p.shape then
      p.shape:moveTo(p.x, p.y)
    end
  end
  
  self.hc:update(tickRate)
end

function Collision:register(obj)
  if obj.shape then
    obj.shape.owner = obj
    self.hc:addShape(obj.shape)
    return
  end
  
  local shape
  if obj.collision.shape == 'rectangle' then
    shape = self.hc:addRectangle(obj.x, obj.y, obj.width, obj.height)
  elseif obj.collision.shape == 'circle' then
    shape = self.hc:addCircle(obj.x, obj.y, obj.radius)
  end

  if obj.collision.static then
    self.hc:setPassive(shape)
  end

  obj.shape = shape
  shape.owner = obj
end

function Collision:unregister(obj)
  self.hc:remove(obj.shape)
end

function Collision:pointTest(x, y, options)
  options = options or {}
  local tag, fn = options.tag, options.fn
  
  for _, shape in pairs(self.hc:shapesAt(x, y)) do
    if (not tag) or shape.owner.collision.tag == tag then
      if (not fn) or fn(shape.owner) then
        return shape.owner
      end
    end
  end
  
  return nil
end

function Collision:lineTest(x1, y1, x2, y2, options)
  local dis = math.distance(x1, y1, x2, y2)
  local _x1, _y1 = math.min(x1, x2), math.min(y1, y2)
  local _x2, _y2 = math.max(x1, x2), math.max(y1, y2)
  local tag, fn, first = options.tag, options.fn, options.first
  local mindis = first and math.huge or nil
  local res = nil
  
  for shape in pairs(self.hc:shapesInRange(_x1, _y1, _x2, _y2)) do
    if (not tag) or shape.owner.collision.tag == tag then
      local intersects, d = shape:intersectsRay(x1, y1, x2 - x1, y2 - y1)
      if intersects and d <= 1 then
        if (not fn) or fn(shape.owner) then
          if not first then
            return shape.owner, d * dis
          elseif d * dis < mindis then
            mindis = d * dis
            res = shape.owner
          end
        end
      end
    end
  end
  
  return res, mindis
end

function Collision:circleTest(x, y, r, options)
  local circle = self.hc:addCircle(x, y, r)
  local tag, fn = options.tag, options.fn
  
  for shape in pairs(circle:neighbors()) do
    if circle:collidesWith(shape) then
      if (not tag) or shape.owner.collision.tag == tag then
        if (not fn) or fn(shape.owner) then
          self.hc:remove(circle)
          return shape.owner
        end
      end
    end
  end
  
  self.hc:remove(circle)
end
