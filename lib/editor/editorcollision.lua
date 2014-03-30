local hardon = require 'lib/hardon'
local cellSize = 128

EditorCollision = class()

function EditorCollision:init()
  self.hc = hardon(cellSize)
end

function EditorCollision:update()
  self.hc:update(tickRate)
end

function EditorCollision:register(obj)
  if not obj.shape then
    assert(obj.collision)
    local shape
    if obj.collision.shape == 'rectangle' then
      shape = self.hc:addRectangle(obj.x, obj.y, obj.width, obj.height)
    elseif obj.collision.shape == 'circle' then
      shape = self.hc:addCircle(obj.x, obj.y, obj.radius)
    end

    if obj.collision.solid then
      self.hc:setPassive(shape)
    end

    obj.shape = shape
    shape.owner = obj
  end
end

