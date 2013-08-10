data = {}
data.load = function()
	local function load(dir, type, fn)
		data[type] = {}
		local id = 1
		for _, file in ipairs(love.filesystem.enumerate(dir)) do
		  if file:match('\.lua') then
		    local obj = love.filesystem.load(dir .. '/' .. file)()
		    obj.id = id
		    id = id + 1
		    data[type][obj.code] = obj
		    f.exe(fn, obj)
		  end
		end
	end

	load('data/weapon', 'weapon')
	load('data/skill', 'skill')
	load('data/buff', 'buff')
	load('data/spell', 'spell')
	load('data/class', 'class', function(class)
	  class.sprite = love.graphics.newImage(class.sprite)
	end)
	data.classes = {[1] = data.class.brute, [data.class.brute] = 1}
end