fx = {}

fx.outline = {
  code = [[
    extern number size;

    vec2 clamp(vec2 pos) {
      number x = pos.x;
      number y = pos.y;
      if (x < 0.0) x = 0.0;
      if (y < 0.0) y = 0.0;
      if (x > 1.0) x = 1.0;
      if (y > 1.0) y = 1.0;
      return vec2(x, y);
    }

    vec4 effect ( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {
      number a = 0.0;
      number n = 0.0;
      for(number x = -10; x <= 10; x += 1) {
        for(number y = -10; y <= 10; y += 1) {
          vec4 color = Texel(texture, clamp(vec2(texture_coords.x + x / size, texture_coords.y + y / size)));
          a += color.a;
          n++;
        }
      }
      
      return vec4(color.r, color.g, color.b, a / n);
    }
  ]],
  
  pre = function(self, ...)
    local size = ...
    size = (1 - math.sqrt(size)) * 1000
    self.shader:send('size', size)
  end
}

function fx:set(name, ...)
  local effect = self[name]
  effect.shader = effect.shader or love.graphics.newShader(effect.code)
  effect:pre(...)
  love.graphics.setShader(effect.shader)
end

function fx:unset()
  love.graphics.setShader()
end