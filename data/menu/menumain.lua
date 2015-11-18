MenuMain = class()

local g = love.graphics

function MenuMain:activate()
  ctx.ribbon.count = 4
  ctx.ribbon.margin = .1

  if love.system.getClipboardText():match('%d+%.%d+%.%d+%.%d+') then
    ctx:connect(love.system.getClipboardText())
  end
end

function MenuMain:draw()
  local u, v = ctx.u, ctx.v
  local anchor = (.3 + (.8 - .3) / 2) * v

  g.setFont('BebasNeue', .065 * v)
  g.setColor(160, 160, 160)

  g.printCenter('Host Game', .05 * u, anchor - ctx.ribbon.margin * v * 1.5, false, true)
  g.printCenter('Join Game', .05 * u, anchor - ctx.ribbon.margin * v * .5, false, true)
  g.printCenter('Editor', .05 * u, anchor + ctx.ribbon.margin * v * .5, false, true)
  g.printCenter('Exit', .05 * u, anchor + ctx.ribbon.margin * v * 1.5, false, true)
end

function MenuMain:mousepressed(x, y, button)
  if button == 'l' then
    local ribbon = ctx.ribbon:test(x, y)

    if ribbon == 1 then self:host()
    elseif ribbon == 2 then self:join()
    elseif ribbon == 3 then self:edit()
    elseif ribbon == 4 then love.event.quit() end
  end
end

function MenuMain:host()
  local success = Goregous:createServer()
  if success then
    local server = app.core.context:add(app.core.server)
    server.owner = username
    ctx:connect('localhost')
  else
    ctx.alert:show('Problem creating server.')
  end
end

function MenuMain:join()
  ctx:push('serverlist')
end

function MenuMain:edit()
  app.core.context:remove(ctx)
  app.core.context:add(app.editor.context, ctx.options.data)
end
