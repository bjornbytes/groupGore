extern number playerDirection;
extern vec2 playerPosition;
extern vec4 frame;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  screen_coords.x -= frame.x;
  screen_coords.y = (frame.y + frame.w) - screen_coords.y;
  vec4 result = Texel(texture, texture_coords);

  float dir = atan(screen_coords.y - playerPosition.y, screen_coords.x - playerPosition.x) * (180 / 3.14159265);
  float diff = abs(mod((mod(playerDirection - dir, 360.0) + 540), 360) - 180);

  float diminish = ((clamp(diff, 90, 160) - 90) / (160 - 90)) * .3;
  result.rgb *= 1 - diminish;

  return result * color;
}