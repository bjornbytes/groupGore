extern vec4 frame;
extern number radius;
extern number smooth;
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  vec4 output = Texel(texture, texture_coords);
  
  screen_coords += frame.xy;
  vec2 position = (screen_coords.xy / frame.zw) - vec2(0.5);
  float len = length(position);
  float vignette = smoothstep(radius, radius - smooth, len);
  output.rgb *= vignette;

  return output * color;
}