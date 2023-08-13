
-- unroll convolution loop
local function build_nightcolor_shader()
	return love.graphics.newShader [[
		extern float opacity;
		extern float lightness;
		vec4 effect(vec4 colour, Image tex, vec2 tc, vec2 sc)
		{
			vec4 spr = Texel(tex, tc);
			float maxc = max(spr.r, max(spr.g, spr.b));
  		    return vec4(spr.r * 0.2 * lightness, spr.g * 0.2 * lightness, (maxc + 0.05) * lightness, spr.a * colour.a * opacity);
		}
	]]
end

return {
description = "Twilight color",

new = function(self)
	self.canvas = love.graphics.newCanvas()
	self.shader = build_nightcolor_shader()
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