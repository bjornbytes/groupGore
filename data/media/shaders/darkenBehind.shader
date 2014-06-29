extern number playerDirection;
extern vec2 playerPosition;
extern number screenHeight;

#extension GL_EXT_gpu_shader4 : enable

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  screen_coords.y = screenHeight - screen_coords.y;
  vec4 output = Texel(texture, texture_coords);

  int dir = int(atan(screen_coords.y - playerPosition.y, screen_coords.x - playerPosition.x) * (180 / 3.14159265));
  int diff = abs(((((int(playerDirection) - dir) % 360) + 540) % 360) - 180);

  float diminish = ((clamp(float(diff), 90, 160) - 90) / (160 - 90)) * .3;
  output.rgb *= 1 - diminish;

  return output * color;
}