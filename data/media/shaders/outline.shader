extern number size;
extern vec2 dimensions;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  number minDis = 1;
  number a = vec4(0);
  number n = 0;
  for(number x = -size; x <= size; x++) {
    for(number y = -size; y <= size; y++) {
      vec4 c = Texel(texture, texture_coords + vec2(x / dimensions.x, y / dimensions.y));
      if(c.a > 0) {
      	n = n + 1;
      	a += c.a;
        number d = sqrt(x * x + y * y) / sqrt(size * size);
        if(d < minDis){minDis = d;}
      }
    }
  }

  a /= n;

  return vec4(color.rgb, color.a * (a - minDis));
}