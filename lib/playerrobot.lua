PlayerRobot = extend(Player)

function PlayerRobot:activate()
  PlayerServer.activate(self)

  self.username = 'robot'
  
  self.s1 = math.floor(math.random() * 300)
  self.s2 = math.floor(math.random() * 300)
  self.s3 = math.floor(math.random() * 300)
  self.s4 = math.floor(math.random() * 300)

  self.input.mx = self.x
  self.input.my = self.y
end

function PlayerRobot:logic()
  --[[
    Variables you can set:

    self.input.w, self.input.a, self.input.s, self.input.d = the WASD keys
    self.input.mx, self.input.my = the mouse positon
    self.input.l, self.input.r = the mouse buttons
    self.input.weapon, self.input.skill = the weapon/skill you have selected
    self.input.reload = the reload key
  ]]
  
  self.input.a = tick % self.s1 < self.s4 / 2
  self.input.d = tick % self.s2 < self.s3 / 2
  self.input.s = tick % self.s3 < self.s2 / 2
  self.input.w = tick % self.s4 < self.s1 / 2

  if tick % self.s4 == 0 then
    self.s1 = math.floor(math.random() * 300)
    self.s2 = math.floor(math.random() * 300)
    self.s3 = math.floor(math.random() * 300)
    self.s4 = math.floor(math.random() * 300)
    self.input.mx = self.x
    self.input.my = self.y
  end

  self.input.mx = self.input.mx - 30 + math.random(60)
  self.input.my = self.input.my - 30 + math.random(60)
end
