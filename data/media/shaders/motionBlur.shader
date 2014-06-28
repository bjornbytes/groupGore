extern vec2 velocity;
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  if(length(velocity) < 4) {
    return Texel(texture, texture_coords) * color;
  }

  vec4 output = Texel(texture, texture_coords) * .5;
  texture_coords -= velocity / 350;
  output += Texel(texture, texture_coords) * .3;
  texture_coords -= velocity / 350;
  output += Texel(texture, texture_coords) * .2;

  return output * color;
}