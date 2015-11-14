local Tree = {}
Tree.name = 'Tree'
Tree.code = 'tree'

Tree.collision = {}
Tree.collision.shape = 'circle'

function Tree:activate(map)
  ctx.event:emit('collision.attach', {object = self})
  self.depth = -5
  if ctx.view then ctx.view:register(self) end
end

function Tree:update()
  if ctx.view then
    self.depth = -2000 + math.distance(ctx.view.x + ctx.view.width / 2, ctx.view.y + ctx.view.height / 2, self.x, self.y)
  end
end

function Tree:draw()
  local x, y = ctx.view:three(self.x, self.y, 100)
  local image = data.media.graphics.map.tree
  if ctx.id and ctx.players:get(ctx.id) and ctx.players:get(ctx.id).active then
    local p = ctx.players:get(ctx.id)
    local alpha = (math.clamp(math.distance(self.x, self.y, p.x, p.y), 60, 120) / 120) * 255
    love.graphics.setColor(255, 255, 255, alpha)
  else
    love.graphics.setColor(255, 255, 255)
  end
  love.graphics.draw(image, x, y, 0, self.radius / 20, self.radius / 20, image:getWidth() / 2, image:getHeight() / 2)
end

function Tree:__tostring()
  return [[{
    kind = 'tree',
    x = ]] .. self.x .. [[,
    y = ]] .. self.y .. [[,
    radius = ]] .. self.radius .. [[
  }]]
end

return Tree
