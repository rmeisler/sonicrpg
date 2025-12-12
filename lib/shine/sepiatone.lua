
-- unroll convolution loop
local function build_sepiatone_shader()
	return love.graphics.newShader [[
		extern float opacity;
		extern float lightness;
		vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
			vec4 texColor = Texel(texture, texture_coords);

			// Convert to grayscale (luminance method)
			float gray = dot(texColor.rgb, vec3(0.299, 0.587, 0.114)); // Standard luminance weights

			// Define your sepia color (warm browns/yellows)
			vec3 sepiaTint = vec3(0.96, 0.64, 0.38); // Example values, adjust for desired tint

			// Mix original color with the tinted gray
			vec3 sepiaColor = mix(vec3(gray), sepiaTint, 0.3); // Mix with 75% tint, adjust factor
			// Or just: vec3 sepiaColor = vec3(gray) * sepiaTint;

			return vec4(sepiaColor * lightness, texColor.a * opacity); // Apply to original alpha
		}
	]]
end

return {
description = "Sepia Tone",

new = function(self)
	self.canvas = love.graphics.newCanvas()
	self.shader = build_sepiatone_shader()
end,

draw = function(self, func, ...)
	local s = love.graphics.getShader()
	local co = {love.graphics.getColor()}
	love.graphics.setShader(self.shader)

	func()

	-- restore blendmode, shader and canvas
	love.graphics.setShader(s)
end,

set = function(self, key, value)
	return self
end
}