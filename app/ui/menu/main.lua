local Main = class()

local g = love.graphics

function Main:activate()
  ctx.ribbon.count = 4
  ctx.ribbon.margin = .1

  if love.system.getClipboardText():match('%d+%.%d+%.%d+%.%d+') then
    ctx:connect(love.system.getClipboardText())
  end
end

function Main:draw()
  local u, v = ctx.u, ctx.v
  local anchor = (.3 + (.8 - .3) / 2) * v

  g.setFont('BebasNeue', .065 * v)
  g.setColor(160, 160, 160)

  g.printCenter('Host Game', .05 * u, anchor - ctx.ribbon.margin * v * 1.5, false, true)
  g.printCenter('Join Game', .05 * u, anchor - ctx.ribbon.margin * v * .5, false, true)
  g.printCenter('Editor', .05 * u, anchor + ctx.ribbon.margin * v * .5, false, true)
  g.printCenter('Exit', .05 * u, anchor + ctx.ribbon.margin * v * 1.5, false, true)
end

function Main:mousepressed(x, y, button)
  if button == 'l' then
    local ribbon = ctx.ribbon:test(x, y)

    if ribbon == 1 then self:host()
    elseif ribbon == 2 then self:join()
    elseif ribbon == 3 then self:edit()
    elseif ribbon == 4 then love.event.quit() end
  end
end

function Main:host()
  local success = app.net.goregous:createServer()
  if success then
    local server = app.util.context:add(app.context.server)
    server.owner = username
    ctx:connect('localhost')
  else
    ctx.alert:show('Problem creating server.')
  end
end

function Main:join()
  ctx:push('serverlist')
end

function Main:edit()
  app.util.context:remove(ctx)
  app.util.context:add(app.context.editor, ctx.options.data)
end

return Main
