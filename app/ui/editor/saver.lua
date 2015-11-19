local Saver = class()

function Saver:keypressed(key)
  if key == 's' and love.keyboard.isDown('lctrl') then
    self:save()
  end
end

function Saver:save()
  local str = 'return {'
  table.each(ctx.map.props, function(p)
    str = str .. p
  end)
  str = str .. '}'
  love.filesystem.createDirectory('maps/' .. ctx.map.code)
  love.filesystem.write('maps/' .. ctx.map.code .. '/props.lua', str)
end

return Saver
