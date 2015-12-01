local Collision = class()
Collision.cellSize = 128

local check = {}

function Collision:init()
  self.hc = require 'lib/hc'
  ctx.event:on('collision.attach', f.cur(self.attach, self))
  ctx.event:on('collision.detach', f.cur(self.detach, self))
  ctx.event:on('collision.move', f.cur(self.move, self))
end

function Collision:attach(data)
  local obj = data.object

  local shape
  if obj.collision.shape == 'rectangle' then
    shape = self.hc.rectangle(obj.x, obj.y, obj.width, obj.height)
  elseif obj.collision.shape == 'circle' then
    shape = self.hc.circle(obj.x, obj.y, obj.radius)
  end

  obj.shape = shape
  shape.owner = obj

  return shape
end

function Collision:detach(data)
  self.hc.remove(data.object.shape)
  data.object.shape = nil
end

function Collision:move(data)
  local x, y = data.x or data.object.x, data.y or data.object.y
  if not x or not y then return end

  if data.object.collision.shape == 'rectangle' then
    x = x + data.object.width / 2
    y = y + data.object.height / 2
  end

  data.object.shape:moveTo(x, y)

  if data.resolve then
    self:resolve(data.object)
  end
end

function Collision:resolve(object)
  local a = object
  local check = {}

  for other, vector in pairs(self.hc.collisions(object.shape)) do
    local b, dx, dy = other.owner, vector.x, vector.y
    f.exe(a.collision.with and a.collision.with[b.collision.tag], a, b, dx, dy)
    f.exe(b.collision.with and b.collision.with[a.collision.tag], b, a, -dx, -dy)
  end
end

function Collision:pointTest(x, y, options)
  options = options or {}
  local tag, fn = options.tag, options.fn
  local detector = self.hc.point(x, y)

  for _, shape in pairs(self.hc.collisions(detector)) do
    if not tag or shape.owner.collision.tag == tag then
      if not fn or fn(shape.owner) then
        self.hc.remove(detector)
        return shape.owner
      end
    end
  end

  self.hc.remove(detector)
  return nil
end

function Collision:lineTest(x1, y1, x2, y2, options)
  local dis = math.distance(x1, y1, x2, y2)
  local _x1, _y1 = math.min(x1, x2), math.min(y1, y2)
  local _x2, _y2 = math.max(x1, x2), math.max(y1, y2)
  local tag, fn, first, all = options.tag, options.fn, options.first, options.all
  local mindis = first and math.huge or nil
  local res = all and {} or nil

  for shape in pairs(self.hc:hash():shapes()) do
    if (not tag) or shape.owner.collision.tag == tag then
      local intersects, d = shape:intersectsRay(x1, y1, x2 - x1, y2 - y1)
      if intersects and d >= 0 and d <= 1 then
        if (not fn) or fn(shape.owner) then
          if not first then
            if all then
              table.insert(res, shape.owner)
            else
              return shape.owner, d * dis
            end
          elseif d * dis < mindis then
            mindis = d * dis
            res = shape.owner
          end
        end
      end
    end
  end

  return res, first and mindis or nil
end

function Collision:circleTest(x, y, r, options)
  local detector = self.hc.circle(x, y, r)
  local tag, fn, all = options.tag, options.fn, options.all
  local res = all and {} or nil

  for shape in pairs(self.hc.collisions(detector)) do
    if (not tag) or shape.owner.collision.tag == tag then
      if (not fn) or fn(shape.owner) then
        if all then
          table.insert(res, shape.owner)
        else
          self.hc.remove(detector)
          return shape.owner
        end
      end
    end
  end

  self.hc.remove(detector)
  return res
end

return Collision
