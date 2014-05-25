local tiles = {}
local function t(x) table.insert(tiles, x) end

-- background
for x = 0, map.width, map.textures.background[3] do
  for y = 0, map.height, map.textures.background[4] do
    t({'background', x, y})
  end
end

-- metal
t({'metal', 544, 416})
t({'metal', 608, 416})
t({'metal', 672, 416})
t({'metal', 736, 416})
t({'metal', 800, 416})

t({'metal', 544, 480})
t({'metal', 608, 480})
t({'metal', 672, 480})
t({'metal', 736, 480})

t({'metal', 544, 544})
t({'metal', 608, 544})
t({'metal', 672, 544})

t({'metal', 544, 608})
t({'metal', 608, 608})
t({'metal', 672, 608})

--

t({'metal', 992, 480})
t({'metal', 1056, 480})
t({'metal', 1056, 544})
t({'metal', 1120, 416})
t({'metal', 1120, 480})
t({'metal', 1120, 544})
t({'metal', 1120, 608})

return tiles
