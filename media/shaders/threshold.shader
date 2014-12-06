extern number threshold;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  vec4 result = Texel(texture, texture_coords);
  float luminance = dot(result.rgb, vec3(.2125, .7154, .0721));
  luminance = (result.r + result.g + result.b) / 3.0;
  if(luminance > threshold) {
    return vec4(1.0);
  }
  else {
    return vec4(vec3(0.0), 1.0);
  }
  /*float val = clamp(luminance - threshold, 0, 1) / (1 - threshold);
  result = vec4(val);

  return vec4(result.rgb * color.rgb, result.a);*/
}
