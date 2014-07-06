local Roof = {}
Roof.name = 'Roof'
Roof.code = 'roof'

Roof.z = 64

local function perim(x, y, l, t, w, h)
  local r, b = l + w, t + h

  x, y = math.clamp(x, l, r), math.clamp(y, t, b)

  local dl, dr, dt, db = math.abs(x - l), math.abs(x - r), math.abs(y - t), math.abs(y - b)
  local m = math.min(dl, dr, dt, db)

  if m == dt then return x, t end
  if m == db then return x, b end
  if m == dl then return l, y end
  return r, y
end

function Roof:activate(map)
  if ctx.view then
    ctx.view:register(self)

    if not Roof.texture then 
      local x, y, w, h = map.textures.wall:getViewport()
      Roof.texture = love.graphics.newCanvas(w, h)
      Roof.texture:renderTo(function()
        love.graphics.draw(map.atlas, map.textures.wall)
      end)
      Roof.texture:setWrap('repeat', 'repeat')
    end

    self.alpha = 1

    self.top = love.graphics.newMesh({
      {0, 0, 0, 0},
      {0, 0, 1, 0},
      {0, 0, 1, 1},
      {0, 0, 0, 1}
    }, self.texture)
  end
end

function Roof:update()
  if ctx.view and ctx.id then
    local p = ctx.players:get(ctx.id)
    if math.inside(p.x, p.y, self.x, self.y, self.width, self.height) then
      self.alpha = math.lerp(self.alpha, 0.2, math.min(6 * tickRate, 1))
    else
      self.alpha = math.lerp(self.alpha, 1, math.min(6 * tickRate, 1))
    end

    if not self:inView() then return end
    local x1, y1 = ctx.view.x + ctx.view.width / 2, ctx.view.y + ctx.view.height / 2
    local x2, y2 = perim(x1, y1, self.x, self.y, self.width, self.height)
    self.depth = math.clamp(math.distance(x1, y1, x2, y2) * ctx.view.scale - 1000 - self.z, -4096, -16)
  end
end

function Roof:draw()
  if not self:inView() then return end
  local g, v = love.graphics, ctx.view
  local ulx, uly = v:three(self.x, self.y, self.z)
  local urx, ury = v:three(self.x + self.width, self.y, self.z)
  local llx, lly = v:three(self.x, self.y + self.height, self.z)
  local lrx, lry = v:three(self.x + self.width, self.y + self.height, self.z)
  local w, h = self.width / self.texture:getWidth(), self.height / self.texture:getHeight()

  self.top:setVertex(1, ulx, uly, 0, 0)
  self.top:setVertex(2, urx, ury, w, 0)
  self.top:setVertex(3, lrx, lry, w, h)
  self.top:setVertex(4, llx, lly, 0, h)

  g.setColor(128, 128, 128, 255 * self.alpha)
  g.draw(self.top, 0, 0)
end

function Roof:inView()
  local x, y, w, h = self.x, self.y, self.width, self.height
  local v = ctx.view
  return x + w >= v.x and x <= v.x + v.width and y + h >= v.y and y <= v.y + v.height
end

return Roof
