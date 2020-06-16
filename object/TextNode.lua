local TextNode = class(require "object/DrawableNode")

-- [text] Could be either string or table (e.g. {color1, text1, color2, text2, ..., colorN, textN})
function TextNode:construct(scene, transform, color, text, font, layer, outline)
	self.text = love.graphics.newText(font or FontCache.Consolas, text)
	self.w = self.text:getWidth()
	self.h = self.text:getHeight()
	self.outline = outline or false
	
	if layer ~= false then
		self:addSceneNode(layer or "ui")
	end
end

function TextNode:add(text, wraplimit, alignment, x, y)
	self.text:addf(text, wraplimit, alignment, x, y)
end

function TextNode:draw(override)
	if self.outline then
		-- Draw black outline
		love.graphics.setColor(0,0,0,self.color[4])
		for x=-2,2,2 do
			for y=-2,2,2 do
				love.graphics.draw(self.text, self.transform.x + x, self.transform.y + y, 0, self.transform.sx, self.transform.sy)
			end
		end
	end
	
	-- Draw over outline
	love.graphics.setColor(self.color)
	love.graphics.draw(self.text, self.transform.x, self.transform.y, 0, self.transform.sx, self.transform.sy)
end

function TextNode:drawUntil(charidx)
	if self.outline then
		-- Draw black outline
		love.graphics.setColor(0,0,0,self.color[4])
		for x=-2,2,2 do
			for y=-2,2,2 do
				love.graphics.draw(self.text:sub(1, charidx), self.transform.x + x, self.transform.y + y, 0, self.transform.sx, self.transform.sy)
			end
		end
	end
	
	-- Draw over outline
	love.graphics.setColor(self.color)
	love.graphics.draw(self.text:sub(1, charidx), self.transform.x, self.transform.y, 0, self.transform.sx, self.transform.sy)
end


return TextNode