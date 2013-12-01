local jungleCarnage = {}

----------------
-- Meta
----------------
jungleCarnage.name = 'Jungle Carnage'
jungleCarnage.width = 1600
jungleCarnage.height = 1200


----------------
-- Spawn Points
----------------
jungleCarnage.spawn = {}

jungleCarnage.spawn[purple] = {
    x = 128,
    y = 128
}

jungleCarnage.spawn[orange] = {
    x = jungleCarnage.width - 128,
    y = jungleCarnage.height - 128
}


----------------
-- Functions
----------------
jungleCarnage.activate = function(self)
  self.points = {}
  self.points[purple] = 0
  self.points[orange] = 0
end

jungleCarnage.hud = function(self)
  local str = 'purple: ' .. self.points[purple] .. ', orange: ' .. self.points[orange]
  love.graphics.setColor(255, 255, 255)
  love.graphics.setFont(ovw.hud.font)
  love.graphics.print(str, love.window.getWidth() / 2 - ovw.hud.font:getWidth(str) / 2, 2)
end


----------------
-- Events
----------------
jungleCarnage.on = {}
jungleCarnage.on[evtDead] = function(self, data)
  local team = 1 - ovw.players:get(data.id).team
  self.points[team] = self.points[team] + 1
  if self.points[team] >= 5 then
    ovw.net:emit(evtChat, {message = (team == 0 and 'purple' or 'orange') .. ' team wins!'})
    self.points[purple] = 0
    self.points[orange] = 0
  end
end


----------------
-- Props
----------------
jungleCarnage.props = {
  {
    kind = 'wall',
    x = 128,
    y = 128 + 128,
    w = 192,
    h = 64,
    z = 64
  },
  {
    kind = 'wall',
    x = 128 + 128,
    y = 128,
    w = 64,
    h = 128,
    z = 64
  },
  {
    kind = 'wall',
    x = jungleCarnage.width - (128 + 128 + 64),
    y = jungleCarnage.height - (128 + 128),
    w = 64,
    h = 128,
    z = 64
  },
  {
    kind = 'wall',
    x = jungleCarnage.width - (128 + 192),
    y = jungleCarnage.height - (128 + 128 + 64),
    w = 192,
    h = 64,
    z = 64
  },
  {
    kind = 'wall',
    x = (jungleCarnage.width / 2) - 32,
    y = (jungleCarnage.height / 2) - 128,
    w = 64,
    h = 96,
    z = 64
  },
  {
    kind = 'wall',
    x = (jungleCarnage.width / 2) - 128,
    y = (jungleCarnage.height / 2) - 32,
    w = 96,
    h = 64,
    z = 64
  },
  {
    kind = 'wall',
    x = (jungleCarnage.width / 2) - 32,
    y = (jungleCarnage.height / 2) - 32,
    w = 64,
    h = 160,
    z = 64
  },
  {
    kind = 'wall',
    x = (jungleCarnage.width / 2) + 32,
    y = (jungleCarnage.height / 2) - 32,
    w = 96,
    h = 64,
    z = 64
  },
  {
    kind = 'wall',
    x = (jungleCarnage.width * .25) - 96,
    y = (jungleCarnage.height * .75) - 96,
    w = 192,
    h = 192,
    z = 64
  },
  {
    kind = 'wall',
    x = (jungleCarnage.width * .75) - 96,
    y = (jungleCarnage.height * .25) - 96,
    w = 192,
    h = 192,
    z = 64
  },
  {
    kind = 'wall',
    x = (jungleCarnage.width * .5) - 128,
    y =  256,
    w = 256,
    h = 64,
    z = 64
  },
  {
    kind = 'wall',
    x = (jungleCarnage.width * .5) - 128,
    y = jungleCarnage.height - (256 + 64),
    w = 256,
    h = 64,
    z = 64
  },
  {
    kind = 'tree',
    x = 350,
    y = 350
  }
}

return jungleCarnage