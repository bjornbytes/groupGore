EditorDeletor = class()

local function invoke(x, k, ...) return x.editor[k](x, ...) end

function EditorDeletor:keypressed(key)
  if key == 'delete' then
    table.each(ovw.map.props, function(p)
      if math.inside(ovw.view:mouseX(), ovw.view:mouseY(), invoke(p, 'boundingBox')) then
        ovw.view:unregister(p)
        ovw.map.props = table.filter(ovw.map.props, function(prop) return p ~= prop end)
        ovw.event:emit('prop.destroy', p)
        return true
      end
    end)
  end
end
