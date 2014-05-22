local tiles = {}

-- background
for x = 0, map.width, map.textures.background[3] do
  for y = 0, map.height, map.textures.background[4] do
    table.insert(tiles, {'background', x, y})
  end
end

return tiles
