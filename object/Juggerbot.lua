local Transform = require "util/Transform"

local Ease = require "actions/Ease"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"
local Wait = require "actions/Wait"
local Do = require "actions/Do"
local Repeat = require "actions/Repeat"
local Spawn = require "actions/Spawn"
local YieldUntil = require "actions/YieldUntil"

local SpriteNode = require "object/SpriteNode"
local Bot = require "object/Bot"
local BasicNPC = require "object/BasicNPC"
local Player = require "object/Player"

local Juggerbot = class(Bot)

function Juggerbot:construct(scene, layer, object)
	if self:isRemoved() then
		return
	end
	
	Bot.init(self, true)
	
	self.collision = {}
	
	self.hotspotOffsets = {
		right_top = {x = -20, y = self.sprite.h + 30},
		right_bot = {x = -20, y = 0},
		left_top  = {x = 20, y = self.sprite.h + 30},
		left_bot  = {x = 20, y = 0}
	}
	
	-- Create follow parts
	self.head = SpriteNode(
		scene,
		Transform.relative(self.sprite.transform, Transform(89, 15)),
		nil,
		"juggerbothead",
		nil,
		nil,
		"objects"
	)
	self.leftarm = SpriteNode(
		scene,
		Transform.relative(self.sprite.transform, Transform(30, 30)),
		nil,
		"juggerbotleftarm",
		nil,
		nil,
		"objects"
	)
	self.rightarm = SpriteNode(
		scene,
		Transform.relative(self.sprite.transform, Transform(-10, 30)),
		nil,
		"juggerbotrightarm",
		nil,
		nil,
		"objects"
	)
	
	self.head.sortOrderY = 10000
	self.rightarm.sortOrderY = 10000
	self.leftarm.sortOrderY = 0
	
	self.dropShadow.sprite.transform.sx = 4
	
	--self:addSceneHandler("update", Juggerbot.moveEffects)
	
	self.stepSfx = "juggerbotstep"
	self.walkspeed = 2
end

function Juggerbot:faceLeft()
	self.sprite.transform.sx = -1
	self.head.transform.sx = -1
	self.leftarm.transform.sx = -1
	self.rightarm.transform.sx = -1
	self.head.transform = Transform.relative(self.sprite.transform, Transform(-89, 15))
	self.leftarm.transform = Transform.relative(self.sprite.transform, Transform(-30, 30))
	self.rightarm.transform = Transform.relative(self.sprite.transform, Transform(10, 30))
	self.facingleft = true
end

function Juggerbot:updateDropShadowPos(xonly)
	if self.facingleft then
		self.dropShadow.x = self.x - self.sprite.w*2 - 8
	else
		self.dropShadow.x = self.x + 8
	end
	
	if not xonly then
		self.dropShadow.y = self.y + self.sprite.h*2 - 16
	end
end

function Juggerbot:moveAnim(dir)
	return Serial {
		Parallel {
			Ease(self, "x", function() return self.x + (dir == "left" and -50 or 50) end, 2, "linear"),
			Animate(self.leftarm, "walkright_step1"),
			Animate(self.rightarm, "walkright_step1"),
			Animate(self.sprite, "walkright_step1")
		},
		PlayAudio("sfx", "juggerbotstep", 1.0, true),
		self.scene:screenShake(30,40),
		Wait(1),
		Parallel {
			Ease(self, "x", function() return self.x + (dir == "left" and -50 or 50) end, 2, "linear"),
			Animate(self.leftarm, "walkright_step2"),
			Animate(self.rightarm, "walkright_step2"),
			Animate(self.sprite, "walkright_step2")
		},
		PlayAudio("sfx", "juggerbotstep", 1.0, true),
		self.scene:screenShake(30,40),
		Wait(1)
	}
end

function Juggerbot:fleetHurtAnim()
	local fleet = BasicNPC(
		self.scene,
		{name = "objects"},
		{
			name = "Fleet",
			x = self.x - 800,
			y = self.y + self.sprite.h,
			width = 64,
			height = 64,
			properties = {nocollision = true, sprite = "art/sprites/leon.png", defaultAnim = "fleetfly"}
		}
	)
	fleet.sprite.transform.ox = 42
	fleet.sprite.transform.oy = 42
	fleet.sprite.transform.angle = (math.pi/10)
	self.scene.objectLookup.Fleet = fleet
	self.scene:addObject(fleet)
	
	local ivan = BasicNPC(
		self.scene,
		{name = "objects"},
		{
			name = "Ivan",
			x = self.x - self.sprite.w*1.5,
			y = self.y + self.sprite.h + 40,
			width = 64,
			height = 64,
			properties = {nocollision = true, sprite = "art/sprites/leon.png", defaultAnim = "ivanpush"}
		}
	)
	ivan.sprite.transform.ox = 30
	ivan.sprite.transform.oy = 37
	ivan.sprite.color[4] = 0
	self.scene.objectLookup.Ivan = ivan
	self.scene:addObject(ivan)

	return Serial {
		PlayAudio("sfx", "sonicrunturn", 1.0, true),
		Ease(fleet, "x", self.x + 800, 0.7),

		Do(function()
			fleet.sprite.color[4] = 0
			ivan.sprite.color[4] = 255
		end),
		
		Parallel {
			Serial {
				Do(function()
					fleet.sprite.color[4] = 255
					fleet.sprite.transform.sx = -2
					fleet.sprite.transform.angle = -(math.pi/10)
				end),
				PlayAudio("sfx", "sonicrunturn", 1.0, true),
				Ease(fleet, "x", self.x - 800, 0.7),
				Do(function()
					fleet.sprite.color[4] = 0
				end)
			},
			Serial {
				Wait(0.5),
				PlayAudio("sfx", "smack", 1.0, true),
				Ease(self, "y", function() return self.y + 200 end, 5, "log"),
				Ease(self, "y", function() return self.y - 10 end, 15, "log"),
				Ease(self, "y", function() return self.y + 10 end, 15, "log"),
				Ease(self, "y", function() return self.y - 3 end, 15, "log"),
				Ease(self, "y", function() return self.y + 3 end, 15, "log"),
			},
			Serial {
				YieldUntil(function() return fleet.x < ivan.x end),
				Do(function()
					ivan.sprite.color[4] = 0
				end)
			}
		},
		Ease(self, "y", function() return self.y + 900 end, 3, "quad"),
		Ease(self.sprite.color, 4, 0, 1),
		Animate(ivan.sprite, "ivancross")
	}
end

function Juggerbot:leonHurtAnim()
	local leon = BasicNPC(
		self.scene,
		{name = "objects"},
		{
			name = "Leon",
			x = self.x + self.sprite.w,
			y = self.y + self.sprite.h + 40,
			width = 64,
			height = 64,
			properties = {nocollision = true, sprite = "art/sprites/leon.png", defaultAnim = "leondash"}
		}
	)
	leon.sprite.transform.ox = 37
	leon.sprite.transform.oy = 40
	leon.sprite.color[4] = 0
	self.scene.objectLookup.Leon = leon
	self.scene:addObject(leon)
	
	local fleet = self.scene.objectLookup.Fleet
	return Serial {
	    Do(function()
			fleet.sprite.color[4] = 255
			fleet.x = self.x + 800
			fleet.sprite.transform.sx = -2
			fleet.sprite.transform.angle = -(math.pi/10)
		end),
		PlayAudio("sfx", "sonicrunturn", 1.0, true),
		Ease(fleet, "x", self.x - 800, 0.7),
		Do(function()
			leon.sprite.color[4] = 255
			fleet.sprite.color[4] = 0
		end),

		Animate(self.sprite, "sliced"),
		Parallel {
			PlayAudio("sfx", "slice", 0.1),
			Animate(function()
				return SpriteNode(
					self.scene,
					Transform(self.x + self.sprite.w, self.y + self.sprite.h, 2, 2),
					nil,
					"sparkle",
					nil,
					nil,
					"upper"
				), true
			end, "idle")
		},
		Parallel {
			Animate(self.sprite, "sliced2"),
			Serial {
				Do(function()
					fleet.sprite.color[4] = 255
					fleet.sprite.transform.sx = 2
					fleet.sprite.transform.angle = (math.pi/10)
				end),
				PlayAudio("sfx", "sonicrunturn", 1.0, true),
				Ease(fleet, "x", self.x + 800, 0.7),
				Do(function()
					fleet.sprite.color[4] = 0
				end)
			},
			Serial {
				YieldUntil(function() return fleet.x > leon.x end),
				Do(function()
					leon.sprite.color[4] = 0
				end)
			}
		},
		Repeat(Serial {
			Parallel {
				Ease(self.sprite.color, 4, 0, 20, "quad"),
				Ease(self.dropShadow.sprite.color, 4, 0, 20, "quad"),
				Ease(self.head.color, 4, 0, 20, "quad"),
				Ease(self.leftarm.color, 4, 0, 20, "quad"),
				Ease(self.rightarm.color, 4, 0, 20, "quad")
			},
			Parallel {
				Ease(self.sprite.color, 4, 255, 20, "quad"),
				Ease(self.dropShadow.sprite.color, 4, 0, 20, "quad"),
				Ease(self.head.color, 4, 255, 20, "quad"),
				Ease(self.leftarm.color, 4, 255, 20, "quad"),
				Ease(self.rightarm.color, 4, 255, 20, "quad")
			}
		}, 10),
		Do(function()
			self.sprite.color[4] = 0
			self.dropShadow:remove()
			self.head:remove()
			self.leftarm:remove()
			self.rightarm:remove()
		end),
		Animate(leon.sprite, "leonsword"),
		Wait(1),
		Animate(leon.sprite, "leonswordaway"),
		Animate(leon.sprite, "leonidle"),
	}
end

function Juggerbot:moveEffects(dt)
	if self.sprite.selected == "walkright" then
		self.rightarm:setAnimation("walkright")
		self.leftarm:setAnimation("walkright")
		self.head:setAnimation("walkright")
		
		if  self.head:getFrame() == 3 or
			self.head:getFrame() == 1
		then
			self.scene:run(self.scene:screenShake(30,40))
		end
	else
		self.rightarm:setAnimation("idleright")
		self.leftarm:setAnimation("idleright")
		self.head:setAnimation("idleright")
	end
end

function Juggerbot:remove()
	Bot.remove(self)
	
	self.head:remove()
	self.leftarm:remove()
	self.rightarm:remove()
end


return Juggerbot
