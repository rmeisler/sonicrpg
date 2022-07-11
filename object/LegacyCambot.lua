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

function LegacyCambot:onCaughtPlayer()
	self:removeSceneHandler("update", Bot.investigateUpdate)
	self:addSceneHandler("update", Bot.updateAction)
	self.action:stop()
	self.sprite:setAnimation("idle"..self.manualFacing)

	countdownText = TextNode(
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
				countdownText.color[4] = 255
				countdownText:set("3")
			end),
			Wait(0.5),
			-- 2
			PlayAudio("sfx", "lockon", 1.0, true),
			Do(function()
				countdownText:set("2")
			end),
			Wait(0.5),
			-- 1
			PlayAudio("sfx", "lockon", 1.0, true),
			Do(function()
				countdownText:set("1")
			end),
			Wait(0.5),
			Do(function()
				countdownText:remove()
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
			countdownText:remove()
		end)
	))
end

function LegacyCambot:getFlashlightOffset()
	local facing = self.manualFacing
	if facing == "up" then
		return Transform(self.sprite.transform.x - self.sprite.w, self.sprite.transform.y - self.sprite.h - 10, 2, 2)
	elseif facing == "down" then
		return Transform(self.sprite.transform.x - self.sprite.w + 6, self.sprite.transform.y + self.sprite.h - 10, 2, 2)
	elseif facing == "right" then
		return Transform(self.sprite.transform.x + self.sprite.w - 26, self.sprite.transform.y + self.sprite.h/2 - 14, 2, 2)
	elseif facing == "left" then
		return Transform(self.sprite.transform.x + self.sprite.w/2 - self.flashlightSprite.w*2 + 55, self.sprite.transform.y + self.sprite.h/2 - 16, 2, 2)
	end
end

return LegacyCambot
