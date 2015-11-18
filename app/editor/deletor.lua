local Deletor = class()

local function invoke(x, k, ...) return x.editor[k](x, ...) end

function Deletor:keypressed(key)
  if key == 'delete' then
    table.each(ctx.map.props, function(p)
      if math.inside(ctx.view:worldMouseX(), ctx.view:worldMouseY(), invoke(p, 'boundingBox')) then
        ctx.view:unregister(p)
        ctx.map.props = table.filter(ctx.map.props, function(prop) return p ~= prop end)
        ctx.event:emit('prop.destroy', p)
        return true
      end
    end)
  end
end

return Deletor
