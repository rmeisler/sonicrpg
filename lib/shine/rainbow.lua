
-- unroll convolution loop
local function build_rainbow_shader()
	return love.graphics.newShader [[
		extern number time;
		vec4 effect(vec4 colour, Image tex, vec2 tc, vec2 sc)
		{
  		    return vec4((1.0+sin(time))/2.0, abs(cos(time)), abs(sin(time)), 0.0) + Texel(tex, tc);
		}
	]]
end

return {
description = "Rainbow wheel",

new = function(self)
	self.t = 0
	self.canvas = love.graphics.newCanvas()
	self.shader = build_rainbow_shader()
end,

draw = function(self, func, ...)
	local s = love.graphics.getShader()
	local co = {love.graphics.getColor()}
	love.graphics.setShader(self.shader)
	
	self.t = self.t + 0.16
	self.shader:send("time", self.t)
	func()
	
	-- restore blendmode, shader and canvas
	love.graphics.setShader(s)
end,

set = function(self, key, value)
	return self
end
}