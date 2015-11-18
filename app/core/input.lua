local Input = class()

function Input:init()
  self.keyboardEnabled = true
  self.mouseEnabled = true
end

function Input:mouseDown(b)
  return self.mouseEnabled and love.mouse.isDown(b)
end

function Input:keyDown(k)
  return self.keyboardEnabled and love.keyboard.isDown(k)
end

return Input
