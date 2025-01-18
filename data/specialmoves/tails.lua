local Transform = require "util/Transform"
local Player = require "object/Player"
local SpriteNode = require "object/SpriteNode"
local NPC = require "object/NPC"

return function(player)
	-- Pause controls
	local origUpdate = player.basicUpdate
	
	-- Figure out where we are going to start the extender from and which direction to move
	local lastXForm = Transform(player.transform.x, player.transform.y, 2, 2)
	local deltaX = 0
	local deltaY = 0
	local sortOrderY
	
	player.state = Player.ToIdle[player.state]
	if player.state == Player.STATE_IDLEUP then
		lastXForm.x = lastXForm.x + 40
		lastXForm.y = lastXForm.y + 74
		deltaY = -6
		player.sprite:setAnimation("extendup")
	elseif player.state == Player.STATE_IDLEDOWN then
		lastXForm.x = lastXForm.x + 56
		lastXForm.y = lastXForm.y + 74
		deltaY = 6
		sortOrderY = player.transform.y + player.height*2
		player.sprite:setAnimation("extenddown")
	elseif player.state == Player.STATE_IDLELEFT then
		lastXForm.x = lastXForm.x + 45
		lastXForm.y = lastXForm.y + 72
		deltaX = -6
		sortOrderY = player.transform.y + player.height*2
		player.sprite:setAnimation("extendleft")
	elseif player.state == Player.STATE_IDLERIGHT then
		lastXForm.x = lastXForm.x + 55
		lastXForm.y = lastXForm.y + 72
		deltaX = 6
		sortOrderY = player.transform.y + player.height*2
		player.sprite:setAnimation("extendright")
	end
	
	local retracting = false
	player.extenderPieces = {}
	
	player.extenderarm = SpriteNode(
		player.scene,
		Transform(lastXForm.x - 16 + deltaX * 2, lastXForm.y - 16 + deltaY * 2, 2, 2),
		player.sprite.color,
		"extenderarm",
		nil,
		nil,
		"objects"
	)
	player.extenderarm:setAnimation(player.sprite.selected)
	if sortOrderY then
		player.extenderarm.sortOrderY = sortOrderY
	end
	
	local counter = 0
	player.basicUpdate = function(self, dt)
		self:updateCollisionObj()

		-- Bunny arm extends in the direction specified for N pixels
		-- If arm collides with a special object, either retrieve it (item) or pull player toward object
		if retracting == false then
			local extObject = SpriteNode(
				self.scene,
				Transform.from(lastXForm),
				self.sprite.color,
				"extender",
				nil,
				nil,
				"objects"
			)
			if sortOrderY then
				extObject.sortOrderY = sortOrderY
			end
			
			if  player.state == Player.STATE_IDLEUP and
				extObject.transform.y < self.transform.y
			then
				extObject.sortOrderY = self.transform.y + self.height*2
				self.extenderarm.oldSortOrderY = self.extenderarm.sortOrderY
				self.extenderarm.sortOrderY = self.transform.y + self.height*2
			else
				self.extenderarm.sortOrderY = self.extenderarm.oldSortOrderY or
					self.extenderarm.sortOrderY
			end
			
			table.insert(self.extenderPieces, extObject)
			lastXForm = Transform(lastXForm.x + deltaX, lastXForm.y + deltaY, 2, 2)
			
			-- If extender arm collides with BunnyExtCollision tile
			local wx,wy = self.scene:screenCoordToWorldCoord(
				self.extenderarm.transform.x,
				self.extenderarm.transform.y
			)
			if  (deltaX > 0 and
				not self.scene:canMove(
					wx + self.extenderarm.w*2,
					wy,
					deltaX,
					0,
					"bunnyExtCollisionMap") or
				not self.scene:canMove(
					wx + self.extenderarm.w*2,
					wy + self.extenderarm.h*2,
					deltaX,
					0,
					"bunnyExtCollisionMap")) or
				(deltaX < 0 and
				not self.scene:canMove(
					wx,
					wy,
					deltaX,
					0,
					"bunnyExtCollisionMap") or
				not self.scene:canMove(
					wx,
					wy + self.extenderarm.h*2,
					deltaX,
					0,
					"bunnyExtCollisionMap")) or
				(deltaY > 0 and
				not self.scene:canMove(
					wx,
					wy + self.extenderarm.h*2,
					0,
					deltaY,
					"bunnyExtCollisionMap") or
				not self.scene:canMove(
					wx + self.extenderarm.w*2,
					wy + self.extenderarm.h*2,
					0,
					deltaY,
					"bunnyExtCollisionMap")) or
				(deltaY < 0 and
				not self.scene:canMove(
					wx,
					wy,
					0,
					deltaY,
					"bunnyExtCollisionMap") or
				not self.scene:canMove(
					wx + self.extenderarm.w*2,
					wy,
					0,
					deltaY,
					"bunnyExtCollisionMap"))
			then
				self.scene.audio:playSfx("clink")
				retracting = true
			else
				self.extenderarm.transform.x = self.extenderarm.transform.x + deltaX
				self.extenderarm.transform.y = self.extenderarm.transform.y + deltaY
				
				counter = counter + 1
			end
			
			if  not love.keyboard.isDown("lshift") or
				self.extenderArmColliding or
				#self.extenderPieces == 80
			then
				retracting = true
			end
		elseif #self.extenderPieces > 0 then
			if self.extenderArmColliding then
				local piece = table.remove(self.extenderPieces, 1)
				piece:remove()
				
				if not self.extenderPull then
					self.x = self.x + deltaX
					self.y = self.y + deltaY
					self.dropShadow.x = self.x - 22 + deltaX
					self.dropShadow.y = (self.dropShadowOverrideY or self.y + self.sprite.h - 15) + deltaY
				elseif self.extenderPull.grabbed then
					-- Pull object to us
					self.extenderPull.x = self.extenderPull.x - deltaX
					self.extenderPull.y = self.extenderPull.y - deltaY
					
					if self.extenderPull.state == NPC.STATE_TOUCHING then
						self.extenderPull.grabbed = false
						self.extenderPull.readyToFall = false
					end
				end
				
				for _,piece in pairs(self.extenderPieces) do
					if  (self.x > love.graphics.getWidth()/2) and
						(self.x < self.scene:getMapWidth() - love.graphics.getWidth()/2)
					then
						piece.transform.x = piece.transform.x - deltaX
					end
					
					if  (self.y > love.graphics.getHeight()/2) and
						(self.y < self.scene:getMapHeight() - love.graphics.getHeight()/2)
					then
						piece.transform.y = piece.transform.y - deltaY
						
						if  player.state == Player.STATE_IDLEUP and
							piece.transform.y < self.transform.y
						then
							piece.sortOrderY = nil
						end
					end
				end
			else
				local piece = table.remove(self.extenderPieces)
				piece:remove()
			end
	
			if  ((self.x > love.graphics.getWidth()/2) and
				(self.x < self.scene:getMapWidth() - love.graphics.getWidth()/2)) or
				not self.extenderArmColliding
			then
				self.extenderarm.transform.x = self.extenderarm.transform.x - deltaX
			end
			
			if  ((self.y > love.graphics.getHeight()/2) and
				(self.y < self.scene:getMapHeight() - love.graphics.getHeight()/2)) or
				not self.extenderArmColliding
			then
				self.extenderarm.transform.y = self.extenderarm.transform.y - deltaY
			end
		else
			if not self.extenderPull and self.extenderArmColliding and self.extenderArmColliding.snapToObject then
				self.x = self.extenderArmColliding.x + self.extenderArmColliding.sprite.w
				self.y = self.extenderArmColliding.y + self.extenderArmColliding.sprite.h*2 - self.height
			end
			if self.extenderPull and not self.extenderPull.falling then
				self.extenderPull.grabbed = false
				self.extenderPull.readyToFall = false
			end
			self.extenderarm:remove()
			self.extenderarm = nil
			self.extenderArmColliding = nil
			self.extenderPull = nil
			self.basicUpdate = origUpdate
		end
	end
end