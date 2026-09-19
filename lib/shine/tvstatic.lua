
-- unroll convolution loop
local function build_tvstatic_shader()
	return love.graphics.newShader [[
		extern float time;
        vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
            float noise = fract(sin(dot(sc.xy + vec2(time), vec2(12.9898, 78.233))) * 43758.5453);
            return vec4(vec3(noise), 1.0);
        }
	]]
end

return {
description = "TV static",

new = function(self)
	self.canvas = love.graphics.newCanvas()
	self.shader = build_tvstatic_shader()
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