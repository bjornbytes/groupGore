local lust = {}
lust.actions = {}

lust.trigger = love.event.push

lust.load = function() end

lust.next = function(f) table.insert(lust.actions, {'after', f}) end
lust.wait = function(n) table.insert(lust.actions, {'wait', n}) end

lust.run = function()
  local load = love.load
  love.load = function(...)
    load(...)
    lust.load(...)
  end
  
  local update = love.update
  love.update = function(...)
    local action = lust.actions[1]
    if not action then return love.event.quit() end
    
    if action[1] == 'wait' then
      update(...)
      action[2] = action[2] - 1
      if action[2] == 0 then table.remove(lust.actions, 1) end
      return
    end
    
    update(...)
    
    if action[1] == 'after' then
      action[2](...)
      table.remove(lust.actions, 1)
    end
  end
  
  love.run()
end

return lust