MenuOptions = class()

MenuOptions.defaults = {
	fullscreen = false,
	borderless = true,
	windowWidth = 800,
	windowHeight = 600,
	vsync = false
}

local function safeLoad(file)
  local ok, chunk, result
  ok, chunk = pcall(love.filesystem.load, file)
  if not ok then print(chunk) return nil end
  
  ok, result = pcall(chunk)
  if not ok then print(result) return nil end
  
  return result
end

function MenuOptions:init()
	self.data = table.merge(safeLoad('options.lua'), self.defaults)
end
