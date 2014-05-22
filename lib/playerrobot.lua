PlayerRobot = extend(Player)

function PlayerRobot:activate()
  PlayerServer.activate(self)

  self.username = 'robot'
end

function PlayerRobot:logic()
  --
end
