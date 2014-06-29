extern number amount;
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  vec4 output = vec4(0);

  output += Texel(texture, vec2(texture_coords.x, texture_coords.y - 4.0 * amount)) * .05;
  output += Texel(texture, vec2(texture_coords.x, texture_coords.y - 3.0 * amount)) * .09;
  output += Texel(texture, vec2(texture_coords.x, texture_coords.y - 2.0 * amount)) * .12;
  output += Texel(texture, vec2(texture_coords.x, texture_coords.y - amount)) * .15;
  output += Texel(texture, texture_coords) * .16;
  output += Texel(texture, vec2(texture_coords.x, texture_coords.y + amount)) * .15;
  output += Texel(texture, vec2(texture_coords.x, texture_coords.y + 2.0 * amount)) * .12;
  output += Texel(texture, vec2(texture_coords.x, texture_coords.y + 3.0 * amount)) * .09;
  output += Texel(texture, vec2(texture_coords.x, texture_coords.y + 4.0 * amount)) * .05;

  return output * color;
}