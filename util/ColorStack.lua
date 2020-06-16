local ColorStack = class()

function ColorStack:construct(colors)
	self.cachedColor = {255,255,255,255}
	for _,color in pairs(colors) do
		self:addColor(color)
	end
	self.children = {}
end

function ColorStack:addChild(colorStack)
	table.insert(self.children, colorStack)
end

function ColorStack:addColor(color)
	-- Find the distance between the current color and the new color
	dr = self.cachedColor[1] - color[1]
	dg = self.cachedColor[2] - color[2]
	db = self.cachedColor[3] - color[3]
	da = self.cachedColor[4] - color[4]
	
	d = math.sqrt(dr*dr + dg*dg + db*db + da*da)
	
	-- Normalize
	ndr = dr/d
	ndg = dg/d
	ndb = db/d
	nda = da/d
	
	-- Add new magnitude
	self.cachedColor[1] = self.cachedColor[1] + d * ndr
	self.cachedColor[2] = self.cachedColor[2] + d * ndg
	self.cachedColor[3] = self.cachedColor[3] + d * ndb
	self.cachedColor[4] = self.cachedColor[4] + d * nda

	-- Apply to children
	for k,v in pairs(self.children) do
		self:addColor(color)
	end
end

function ColorStack:getColor()
	return self.cachedColor
end


return ColorStack