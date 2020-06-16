return {
description = "Simple glow shader based on gassian blurring",

new = function(self)
	self.radius_h, self.radius_v = 3, 3
	self.canvas_h, self.canvas_v = love.graphics.newCanvas(), love.graphics.newCanvas()
	self.shader = love.graphics.newShader[[
		vec4 effect(vec4 color, Image texture, vec2 tc, vec2 sc)
		{
			return Texel(texture, tc) + vec4(0,1,0,1) * sin(sc.x)*30;
		}
	]]
end,

draw = function(self, func, ...)
	local s = love.graphics.getShader()
	local co = {love.graphics.getColor()}

	love.graphics.setColor(co)
	love.graphics.setShader(self.shader)

	--func()
	
	self:_render_to_canvas(self.canvas_v,
	                       love.graphics.draw, self.canvas_h, self.radius_h/2,self.radius_v/2)

	-- restore blendmode, shader and canvas
	love.graphics.setShader(s)
	
	func()
end
}