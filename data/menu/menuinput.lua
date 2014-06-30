MenuInput = class()

function MenuInput:init()
  self.inputs = {}
  self.focused = nil
end

function MenuInput:textinput(character)
  if self.focused then
    if character:match('%w') or character == '\b' then
      self.inputs[self.focused].val = self.inputs[self.focused].val .. character
      data.media.sounds.click:play()
    end
  end
end

function MenuInput:keypressed(key)
  if key == 'backspace' and self.focused and #self.inputs[self.focused].val > 0 then
    self.inputs[self.focused].val = self.inputs[self.focused].val:sub(1, -2)
    data.media.sounds.click:play()
  elseif key == 'tab' then
    if not self.focused then
      self:focusInput(self.inputs[1])
    else
      local idx
      for i = 1, #self.inputs do
        if self.inputs[i] == self.focused then idx = i break end
      end
      self:focusInput(self.inputs[idx % #self.inputs + 1])
    end
    data.media.sounds.click:play()
  end
end

function MenuInput:clear()
  self.focused = nil
  table.clear(self.inputs)
end

function MenuInput:addInput(name, default)
  self.inputs[name] = {
    val = default,
    default = default
  }
  
  table.insert(self.inputs, name)
end

function MenuInput:val(name)
  return self.inputs[name].val
end

function MenuInput:focusInput(input)
  self:unfocus()
  self.focused = input
  if self.inputs[self.focused].default == self.inputs[self.focused].val then self.inputs[self.focused].val = '' end
end

function MenuInput:unfocus()
  if not self.focused then return end
  if self.inputs[self.focused].val == '' and self.inputs[self.focused].default then self.inputs[self.focused].val = self.inputs[self.focused].default end
  self.focused = nil
end