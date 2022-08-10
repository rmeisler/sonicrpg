local Transform = require "util/Transform"
local Menu = require "actions/Menu"
local MessageBox = require "actions/MessageBox"
local Rect, Circle = unpack(require "util/Shapes")

local BattleMenu = class(require "object/SceneNode")

function BattleMenu:construct(scene, img, transform, party, opponents)
    self:addSceneNode("ui")
	
	self.img = img
    
	self.party = party
	self.opponents = opponents
	
	self.w = love.graphics.getWidth() - 10
	self.h = 154
	
	self.transform = transform
end

function BattleMenu:draw()
	-- Minor transparency, slightly dark
	love.graphics.setColor(200,200,200,200)

	-- Stats window
	if self.img then
		love.graphics.draw(self.img, self.transform.x, self.transform.y, 0, self.w * self.transform.sx / self.img:getWidth(), self.h * self.transform.sy / self.img:getHeight())
	else
		love.graphics.rectangle("fill", self.transform.x, self.transform.y, self.w * self.transform.sx, self.h * self.transform.sy)
	end
	
	love.graphics.setColor(255,255,255,255)
	
	-- Print opponent names
	love.graphics.setFont(FontCache.Consolas)
	for index,opponent in pairs(self.opponents) do
		love.graphics.print(opponent.name, self.transform.x + 15, self.transform.y + 15 + ((index-1) * 28))
	end
	
	-- Opponent stats (if applicable)
	for _,oppo in pairs(self.opponents) do
		if oppo.showHp then
			local hpPosX = oppo:getSprite().transform.x - oppo:getSprite().w + oppo.hpBarOffset.x
			local hpPosY = oppo:getSprite().transform.y + oppo:getSprite().h + oppo.hpBarOffset.y

			-- Draw back of progress bar
			love.graphics.setColor(0, 0, 0, math.min(oppo.showHpAlpha, 100))
			love.graphics.rectangle("fill", hpPosX, hpPosY, 200, 10, 2, 2)

			-- Draw progress bar
			if oppo.hp > 0 then
				love.graphics.setColor(80, 255, 80, oppo.showHpAlpha)
				love.graphics.rectangle("fill", hpPosX, hpPosY, 200 * (oppo.hp / oppo.maxhp), 10, 2, 2)
			end
			
			-- Align hp text
			local hpText = string.format('%5s / %s', tostring(oppo.hp), tostring(oppo.maxhp))
			
			-- Draw stat text with outline
			love.graphics.setColor(0, 0, 0, math.min(oppo.showHpAlpha))
			for x=-2,2,2 do
				for y=-2,2,2 do
					love.graphics.print(hpText, hpPosX + x + 15, hpPosY + y - 10)
				end
			end
			
			-- Align hp / maxhp
			love.graphics.setColor(255, 255, 255, oppo.showHpAlpha)
			love.graphics.print(hpText, hpPosX + 15, hpPosY - 10)
		end
	end
	
	-- Player names/stats
	for index,player in pairs(self.party) do
		index = index - 1
		love.graphics.print(player.name, self.transform.x + 440, self.transform.y + 15 + (index * 28))
		
		local hpPosX = self.transform.x + 550
		local hpPosY = self.transform.y + 15 + (index * 28)
		
		-- Draw back of progress bar
		love.graphics.setColor(0, 0, 0, 100)
		love.graphics.rectangle("fill", hpPosX - 15, hpPosY + 10, 200, 10, 2, 2)

		-- Draw progress bar
		if player.hp > 0 then
			love.graphics.setColor(80, 255, 80, 255)
			love.graphics.rectangle("fill", hpPosX - 15, hpPosY + 10, 200 * (player.hp / player.stats.maxhp), 10, 2, 2)
		end
		
		-- Align hp text
		local hpText = string.format('%5s / %s', tostring(player.hp), tostring(player.stats.maxhp))
		
		-- Draw stat text with outline
		love.graphics.setColor(0, 0, 0, 100)
		for x=-2,2,2 do
			for y=-2,2,2 do
				love.graphics.print(hpText, hpPosX + x, hpPosY + y)
			end
		end
		
		-- Align hp / maxhp
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.print(hpText, hpPosX, hpPosY)
	end
	
	-- Yellow hp
	love.graphics.setFont(FontCache.ConsolasSmall)
	love.graphics.setColor(255,255,0,255)
	love.graphics.print("hp", self.transform.x + 630, self.transform.y - 2)
	
	love.graphics.setColor(255,255,255,255)
	love.graphics.setFont(FontCache.Consolas)
end


return BattleMenu