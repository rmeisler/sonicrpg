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
local Swatbot = require "object/Swatbot"

local LegacySwatbot = class(Swatbot)

function LegacySwatbot:construct(scene, layer, object)
	
end

function LegacySwatbot:onRemove()
	if self.countdownText then
		self.countdownText:remove()
	end
end

function LegacySwatbot:onCaughtPlayer()
	self:removeSceneHandler("update", Bot.investigateUpdate)
	self:addSceneHandler("update", Bot.updateAction)
	self.action:stop()
	self.sprite:setAnimation("idle"..self.manualFacing)

	self.countdownText = TextNode(
		self.scene,
		Transform.relative(self.sprite.transform, Transform(48, -32)),
		{255, 0, 0, 0},
		"0",
		nil,
		nil,
		true
	)

	self:run(While(
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
					MessageBox{message="Swatbot: Intruder alert!", closeAction=Wait(1)},
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

function LegacySwatbot:getWaitAfterInvestigate()
	return Wait(0.5)
end

function LegacySwatbot:getInitiative()
	local initiative = nil
	if ((self.manualFacing == "left"  and self.x < self.scene.player.x) or
		(self.manualFacing == "right" and self.x > self.scene.player.x) or
		(self.manualFacing == "up"    and self.y < (self.scene.player.y - self.scene.player.sprite.h)) or
		(self.manualFacing == "down"  and (self.y + self.sprite.h) > (self.scene.player.y + self.scene.player.sprite.h)))
	then
		initiative = "player"
	end
	if not self.behavior then
		return nil
	end
	return self.behavior <= Bot.BEHAVIOR_INVESTIGATING and initiative or "opponent"
end

return LegacySwatbot
