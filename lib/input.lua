Input = class()

function Input:init()
  self.inputs = {}
  self.focused = nil
end

function Input:textinput(character)
  if self.focused then
    if character:match('%w') then self.inputs[self.focused].val = self.inputs[self.focused].val .. character end
  end
end

function Input:keypressed(key)
  if key == 'backspace' and self.focused then
    self.inputs[self.focused].val = self.inputs[self.focused].val:sub(1, -2)
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
  end
end

function Input:addInput(name, default)
  self.inputs[name] = {
    val = default,
    default = default
  }
  
  table.insert(self.inputs, name)
end

function Input:val(name)
  return self.inputs[name].val
end

function Input:focusInput(input)
  self:unfocus()
  self.focused = input
  if self.inputs[self.focused].default == self.inputs[self.focused].val then self.inputs[self.focused].val = '' end
end

function Input:unfocus()
  if not self.focused then return end
  if self.inputs[self.focused].val == '' and self.inputs[self.focused].default then self.inputs[self.focused].val = self.inputs[self.focused].default end
  self.focused = nil
end