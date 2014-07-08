HudKillPopup = class()

local g = love.graphics

function HudKillPopup:init()
  self.streak = {}
  self.multikill = {}
  self.multikillTick = {}
  self.feed = {}
  ctx.event:on(evtDead, function(data)
    self.streak[data.id] = 0
    if data.id ~= data.kill then
      self.multikill[data.kill] = self.multikill[data.kill] or 0
      if not self.multikillTick[data.kill] or (tick - self.multikillTick[data.kill]) * tickRate > math.min(4 + self.multikill[data.kill] / 2, 6) then
        self.multikill[data.kill] = 1
      else
        self.multikill[data.kill] = self.multikill[data.kill] + 1
      end
      self.multikillTick[data.kill] = tick

      self.streak[data.kill] = (self.streak[data.kill] or 0) + 1
      local u, v = ctx.hud.u, ctx.hud.v
      if self.streak[data.kill] == 3 or self.streak[data.kill] == 5 or self.streak[data.kill] == 8 then
        table.insert(self.feed, 1, {player = data.kill, kind = 'streak', amount = self.streak[data.kill], x = u * .5, y = -v * .1, alpha = 3})
      end
      if self.multikill[data.kill] >= 2 then
        table.insert(self.feed, 1, {player = data.kill, kind = 'multikill', amount = self.multikill[data.kill], x = u * .5, y = -v * .1, alpha = 3})
      end

    end
  end)
end

function HudKillPopup:update()
  local u, v = ctx.hud.u, ctx.hud.v
  local ty = v * .22
  for i = 1, #self.feed do
    if i > #self.feed then break end
    self.feed[i].x = math.lerp(self.feed[i].x, u * .5, math.min(10 * tickRate, 1))
    self.feed[i].y = math.lerp(self.feed[i].y, ty, math.min(10 * tickRate, 1))
    local height
    if self.feed[i].kind == 'multikill' then height = v * .06 + (v * .008 * (self.feed[i].amount - 2))
    elseif self.feed[i].kind == 'streak' then height = v * .06 + (v * .008 * (self.feed[i].amount - 3) / 2) end
    ty = ty + (v * .035) + height + (v * .03)
    self.feed[i].alpha = self.feed[i].alpha - tickRate
    if self.feed[i].alpha <= 0 then
      table.remove(self.feed, i)
      i = i - 1
    end
  end
end

function HudKillPopup:draw()
  local u, v = ctx.hud.u, ctx.hud.v
  for i = 1, #self.feed do
    local f = self.feed[i]
    local p = ctx.players:get(f.player)
    if f.kind == 'streak' then str = p.username .. ' is on a'
    elseif f.kind == 'multikill' then str = p.username .. ' just scored a' end
    g.setColor(255, 255, 255, 255 * math.min(f.alpha, 1))
    g.setFont('BebasNeue', v * .035)
    g.printCenter(str, f.x, f.y, true, false)

    local height
    if f.kind == 'multikill' then
      height = v * .06 + (v * .01 * (f.amount - 2))
      local multipliers = {[2] = 'double', [3] = 'triple', [4] = 'quadra', [5] = 'monster'}
      str = multipliers[math.min(f.amount, #multipliers)] .. ' kill'
    elseif f.kind == 'streak' then
      height = v * .06 + (v * .01 * (f.amount - 3) / 2)
      local streaks = {[3] = 'killing spree', [5] = 'bloodbath', [8] = 'massacre'}
      str = streaks[math.min(f.amount, #streaks)]
    end
    g.setFont('BebasNeue', height)
    g.printCenter(str, f.x, f.y + v * .038, true, false)
  end
end