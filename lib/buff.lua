Buff = class()

function Buff:init()
  self.timer = self.duration
  self.undo = {}
end

function Buff:update()
  if self.timer and self.timer > 0 then
    self.timer = self.timer - math.min(self.timer, 1 * tickRate)
    if self.timer == 0 then
      return true
    end
  end
end