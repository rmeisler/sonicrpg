local MessageBox = require "actions/MessageBox"
local Do = require "actions/Do"
local Ease = require "actions/Ease"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local Repeat = require "actions/Repeat"
local Executor = require "actions/Executor"
local Animate = require "actions/Animate"

local Transform = require "util/Transform"
local SpriteNode = require "object/SpriteNode"

local NPC = require "object/NPC"

local FadePlatform = class(NPC)

function FadePlatform:construct(scene, layer, object)
	self.ghost = true
	self.alignment = NPC.ALIGN_TOPLEFT
	
	NPC.init(self)
	
	if self.sprite then
		self.edge = SpriteNode(
			self.scene,
			Transform(self.x, self.y, 2, 2),
			self.sprite.color,
			"fadeplatformedge",
			nil,
			nil,
			"objects"
		)
	end

	-- Init touhing count, if not already
	if not self.scene.touchingPlatforms then
		self.scene.touchingPlatforms = {}
	end
	
	-- Remove NPC update func and add our own
	self:removeSceneHandler("update", NPC.update)
	self:addSceneHandler("update")
end

function FadePlatform:update(dt)
	if self.scene.dead then return end
	self.edge.transform.x = self.sprite.transform.x
	self.edge.transform.y = self.sprite.transform.y
	
	-- Sort below player
	self.edge.sortOrderY = self.sprite.transform.y - self.sprite.h*2
	self.sprite.sortOrderY = self.sprite.transform.y - self.sprite.h*2
	
	local prevState = self.state
	
	-- Check if we are colliding with player
	if  self.scene.player:isTouching(self.x, self.y, self.object.width, self.object.height) then
		self.state = NPC.STATE_TOUCHING
	else
		self.state = NPC.STATE_IDLE
	end
	
	if prevState ~= NPC.STATE_TOUCHING and self.state == NPC.STATE_TOUCHING then
		self.scene.touchingPlatforms[tostring(self)] = self
		if not self.animation then
			self.animation = Serial {
				Animate(self.sprite, self.object.properties.disappearAnim or "disappear"),
				Animate(self.sprite, "gone"),
				Do(function()
					local touching = table.count(self.scene.touchingPlatforms)
					
					-- No longer touching this platform
					self.scene.touchingPlatforms[tostring(self)] = nil
					
					if  touching == 1 and not self.scene.player.falling and
						not (GameState.leader == "sonic" and
							self.scene.player.doingSpecialMove)
					then
						self.scene.player.falling = true
						
						-- Fall to your doom
						local origUpdate = self.scene.player.basicUpdate
						self.scene.player.basicUpdate = function(player, dt) end
						self.scene.player.doingSpecialMove = false
						self.scene.player.cinematic = true
						
						self:run {
							Parallel {
								Animate(self.scene.player.sprite, "shock"),
								Ease(self.scene.player, "y", self.scene:getMapHeight() + self.scene.player.sprite.h*2, 1),
								Ease(self.scene.player.sprite.color, 4, 0, 1.5)
							},
							Do(function()
								-- Reposition player at last safe platform
								self.scene.player.x = self.scene.lastSafePlatform.x + self.scene.lastSafePlatform.object.width/2
								self.scene.player.y = self.scene.lastSafePlatform.y - self.scene.lastSafePlatform.object.height
								self.scene.player.basicUpdate = self.scene.player.origUpdate or origUpdate
								self.scene.player.state = "idledown"
								self.scene.player.falling = false
								self.scene.player.cinematic = false
							end),
							-- Blink transparency
							Repeat(
								Serial {
									Ease(self.scene.player.sprite.color, 4, 0, 20, "quad"),
									Ease(self.scene.player.sprite.color, 4, 255, 20, "quad")
								},
								10
							),
							Do(function()
								self.scene.player.cinematic = false
								self.scene.player.basicUpdate = self.scene.player.origUpdate
								self.scene.player.origUpdate = nil
								self.scene.player.doingChangeChar = false
								
								-- Update keyhint
								self.scene.player:removeKeyHint()
							end)
						}
					end
					
					-- Drop whatever enemy defined on dropOnDisappear, if set
					if self.object.properties.dropOnDisappear then
						local obj = self.scene.objectLookup[self.object.properties.dropOnDisappear]
						if obj then
							obj:drop()
						end
						self.object.properties.dropOnDisappear = nil
					end
				end),
				Wait(0.5),
				Animate(self.sprite, "reappear"),
				Do(function()
					self.sprite:setAnimation("idle")
					self.animation = nil
				end)
			}
			Executor(self.scene):act(self.animation)
		end
	elseif self.state ~= NPC.STATE_TOUCHING then
		self.scene.touchingPlatforms[tostring(self)] = nil
	end
end

function FadePlatform:remove()
	NPC.remove(self)
	self.edge:remove()
end

return FadePlatform
