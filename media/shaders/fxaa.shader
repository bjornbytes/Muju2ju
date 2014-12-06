extern vec2 stepsize;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  float FXAA_SPAN_MAX = 8.0;
  float FXAA_REDUCE_MUL = 1.0 / 8.0;
  float FXAA_REDUCE_MIN = (1.0 / 128.0);

  vec3 rgbNW = Texel(texture, texture_coords + (vec2(-1.0, -1.0) * stepsize)).rgb;
  vec3 rgbNE = Texel(texture, texture_coords + (vec2(1.0, -1.0) * stepsize)).rgb;
  vec3 rgbSW = Texel(texture, texture_coords + (vec2(-1.0, 1.0) * stepsize)).rgb;
  vec3 rgbSE = Texel(texture, texture_coords + (vec2(1.0, 1.0) * stepsize)).rgb;
  vec3 rgbM = Texel(texture, texture_coords).rgb;

  vec3 lum = vec3(.299, .587, .114);
  float lumNW = dot(rgbNW, lum);
  float lumNE = dot(rgbNE, lum);
  float lumSW = dot(rgbSW, lum);
  float lumSE = dot(rgbSE, lum);
  float lumM = dot(rgbM, lum);

  float lumMin = min(lumM, min(min(lumNW, lumNE), min(lumSW, lumSE)));
  float lumMax = max(lumM, max(max(lumNW, lumNE), max(lumSW, lumSE)));

  vec2 dir;
  dir.x = -((lumNW + lumNE) - (lumSW + lumSE));
  dir.y = ((lumNW + lumNE) - (lumSW + lumSE));

  float dirReduce = max((lumNW + lumNE + lumSW + lumSE) * (.25 * FXAA_REDUCE_MUL), FXAA_REDUCE_MIN);
  float rcpDirMin = 1.0 / (min(abs(dir.x), abs(dir.y)) + dirReduce);

  dir = min(vec2(FXAA_SPAN_MAX, FXAA_SPAN_MAX), max(vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX), dir * rcpDirMin)) * stepsize;

  vec3 rgbA = 0.5 * (Texel(texture, texture_coords + dir * (1.0 / 3.0 - 0.5)).rgb + Texel(texture, texture_coords + dir * (2.0 / 3.0 - 0.5)).rgb);
  vec3 rgbB = rgbA * 0.5 + 0.25 *  (Texel(texture, texture_coords + dir * (0.0 / 3.0 - 0.5)).rgb + Texel(texture, texture_coords + dir * (3.0 / 3.0 - 0.5)).rgb);

  float lumB = dot(rgbB, lum);

  if(lumB < lumMin || lumB > lumMax) {
  	return vec4(rgbA, 1.0) * color;
  }
  else {
  	return vec4(rgbB, 1.0) * color;
  }
}
