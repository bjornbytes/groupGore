extern number size;
extern vec2 dimensions;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  vec4 result = Texel(texture, texture_coords);
  return vec4(color.rgb, result.a);
}
