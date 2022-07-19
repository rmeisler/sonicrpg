local Do = require "actions/Do"
local Wait = require "actions/Wait"
local Parallel = require "actions/Parallel"
local Serial = require "actions/Serial"
local MessageBox = require "actions/MessageBox"
local Repeat = require "actions/Repeat"
local Ease = require "actions/Ease"
local PlayAudio = require "actions/PlayAudio"
local BlockPlayer = require "actions/BlockPlayer"
local While = require "actions/While"

local Transform = require "util/Transform"

local SpriteNode = require "object/SpriteNode"
local TextNode = require "object/TextNode"

local Bot = require "object/Bot"
local Cambot = require "object/Cambot"

local LegacyCambot = class(Cambot)

function LegacyCambot:construct(scene, layer, object)
	
end

function LegacyCambot:onRemove()
	if self.countdownText then
		self.countdownText:remove()
	end
end

function LegacyCambot:onCaughtPlayer()
	self:removeSceneHandler("update", Bot.investigateUpdate)
	self:addSceneHandler("update", Bot.updateAction)
	self.action:stop()
	self.sprite:setAnimation("idle"..self.manualFacing)

	self.countdownText = TextNode(
		self.scene,
		Transform.relative(self.sprite.transform, Transform(48, 0)),
		{255, 0, 0, 0},
		"0",
		nil,
		nil,
		true
	)

	self.scene:run(While(
		function()
			return not self:isRemoved()
		end,
		Serial {
			self:hop(),
			-- 3
			PlayAudio("sfx", "lockon", 1.0, true),
			Do(function()
				self.behavior = Bot.BEHAVIOR_CHASING
				self.countdownText.color[4] = 255
				self.countdownText:set("3")
			end),
			Wait(0.5),
			-- 2
			PlayAudio("sfx", "lockon", 1.0, true),
			Do(function()
				self.countdownText:set("2")
			end),
			Wait(0.5),
			-- 1
			PlayAudio("sfx", "lockon", 1.0, true),
			Do(function()
				self.countdownText:set("1")
			end),
			Wait(0.5),
			Do(function()
				self.countdownText:remove()
				self:removeAllSceneHandlers()
			end),
			BlockPlayer {
				-- Alarm sfx + blinking red screen
				Parallel {
					PlayAudio("sfx", "alert", 1.0),
					Repeat(Parallel {
						Serial {
							Ease(self.scene.bgColor, 1, 510, 5, "quad"),
							Ease(self.scene.bgColor, 1, 255, 5, "quad"),
						},
						Do(function() 
							ScreenShader:sendColor("multColor", self.scene.bgColor)
						end)
					}, 5),
					MessageBox{message="Eyebot: Intruder alert!", closeAction=Wait(1)},
					Serial {
						Wait(0.5),
						Do(function()
							self.scene.player.noIdle = true
							self.scene.player.sprite:setAnimation("shock")
						end)
					}
				},
				Do(function()
					self.scene:restart()
				end)
			}
		},
		Do(function()
			self.countdownText:remove()
		end)
	))
end

function LegacyCambot:getWaitAfterInvestigate()
	return Wait(0.5)
end

function LegacyCambot:getInitiative()
	local initiative = nil
	if ((self.manualFacing == "left"  and self.x < self.scene.player.x) or
		(self.manualFacing == "right" and self.x > self.scene.player.x) or
		(self.manualFacing == "up"    and self.y < (self.scene.player.y - self.scene.player.sprite.h)) or
		(self.manualFacing == "down"  and (self.y - self.sprite.h*2) > (self.scene.player.y + self.scene.player.sprite.h)))
	then
		initiative = "player"
	end
	return self.behavior <= Bot.BEHAVIOR_INVESTIGATING and initiative or "opponent"
end

function LegacyCambot:getFlashlightOffset()
	local facing = self.manualFacing
	if facing == "up" then
		return Transform(self.sprite.transform.x - self.sprite.w, self.sprite.transform.y - self.sprite.h - 10, 2, 2)
	elseif facing == "down" then
		return Transform(self.sprite.transform.x - self.sprite.w + 5, self.sprite.transform.y + self.sprite.h - 10, 2, 2)
	elseif facing == "right" then
		return Transform(self.sprite.transform.x + self.sprite.w - 26, self.sprite.transform.y + self.sprite.h/2 - 14, 2, 2)
	elseif facing == "left" then
		return Transform(self.sprite.transform.x + self.sprite.w/2 - self.flashlightSprite.w*2 + 58, self.sprite.transform.y + self.sprite.h/2 - 16, 2, 2)
	end
end

return LegacyCambot
