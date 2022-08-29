local Action = require "actions/Action"
local MessageBox = require "actions/MessageBox"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local While = require "actions/While"
local Animate = require "actions/Animate"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Ease = require "actions/Ease"
local PlayAudio = require "actions/PlayAudio"
local Do = require "actions/Do"
local Executor = require "actions/Executor"
local YieldUntil = require "actions/YieldUntil"

local SpriteNode = require "object/SpriteNode"

local Transform = require "util/Transform"


local KeyTrigger = function(self, key)
	if key == self.sequence[1] then
		table.remove(self.sequence, 1)
		local sprite = table.remove(self.spriteNodes, 1)
		local sfx = "lockon"
		if next(self.sequence) == nil then
			self.earlyExitInterrupt = true
			self.keycodeSuccess = true
			sfx = "levelup"
		end

		self.scene.audio:stopSfx()
		Executor(self.scene):act(Serial {
			PlayAudio("sfx", sfx, 1.0, true),
			Parallel {
				Ease(sprite.transform, "sx", 3, 5),
				Ease(sprite.transform, "sy", 3, 5),
				Ease(sprite.color, 4, 0, 5)
			},
			Do(function()
				sprite:remove()
			end)
		})
	else
		self.scene.audio:playSfx("error", nil, true)
		self.earlyExitInterrupt = true
	end
end

return function(self, target)
	self.doneWithInterrupt = false
	self.earlyExitInterrupt = false

	target.malfunctioningTurns = 3
	target.infectedStats = {attack = self.stats.focus, speed = 100, luck = 0}
	
	local keys = {"up", "down", "left", "right", "x", "z", "c"}
	local fadeIn = {}
	
	self.keycodeSuccess = false
	self.sequence = {}
	self.spriteNodes = {}
	for i=1,5 do
		local key = keys[math.random(1, #keys)]
		table.insert(self.sequence, key)
		
		local sprite = SpriteNode(
			self.scene,
			Transform.fromoffset(self.sprite.transform, Transform(-64 + (i-1)*32, -self.sprite.h)),
			{255,255,255,0},
			"press"..key,
			nil,
			nil,
			"ui"
		)
		sprite:setAnimation("idle")
		table.insert(self.spriteNodes, sprite)
		table.insert(fadeIn, Ease(sprite.color, 4, 255, 1))
	end
	
	target.lostTurns = 2
	target.lostTurnType = "interrupt"
	return Serial {
		Animate(self.sprite, "nichole_start"),
		Animate(self.sprite, "nichole_idle"),
		
		MessageBox {
			message="Nicole: Enter the following sequence for extra damage.",
			rect=MessageBox.HEADLINER_RECT,
			sfx="nichole",
			closeAction=Wait(0.6)
		},
		
		-- Throw up button sprites, all at once, all transparent
		Parallel(fadeIn),
		
		Do(function()
			self.scene:addHandler("keytriggered", KeyTrigger, self)
			self.scene:focus("keytriggered", self) -- HACK, focus past skills + battle menu
			self.scene:focus("keytriggered", self)
			self.scene:focus("keytriggered", self)
		end),
		
		While(
			function() return not self.earlyExitInterrupt end,
			Wait(3),
			Action()
		),
		
		-- Remove temporary keytriggered event
		Do(function()
			self.scene:removeHandler("keytriggered", KeyTrigger, self)
			self.scene:unfocus("keytriggered")
			self.scene:unfocus("keytriggered")
			self.scene:unfocus("keytriggered")
			for _,s in pairs(self.spriteNodes) do
				s:remove()
			end
			
			self.scene:run {
				PlayAudio("sfx", "nicholescan", 1.0, true),
				-- Parallax over enemy
				Do(function()
					target:getSprite():setParallax(2, "blue")
				end),
				Wait(1.6),
				Do(function()
					target:getSprite():removeParallax()
				end),
				
				Parallel {
					Animate(function()
						local xform = Transform(
							target.sprite.transform.x - 50,
							target.sprite.transform.y - 50,
							2,
							2
						)
						return SpriteNode(self.scene, xform, nil, "lightning", nil, nil, "ui"), true
					end, "idle"),
					
					Serial {
						Wait(0.2),
						PlayAudio("sfx", "shocked", 0.5, true),
					}
				},
				target:takeDamage({attack = self.stats.focus, speed = 100, luck = (self.keycodeSuccess and 100 or 0)}),
				
				MessageBox {
					message=target.name.." can't move!",
					rect=MessageBox.HEADLINER_RECT,
					closeAction=Wait(0.6)
				},
				
				Animate(self.sprite, "nichole_retract"),
				Animate(self.sprite, "idle"),
				Do(function()
					self.doneWithInterrupt = true
				end)
			}
		end),
		
		YieldUntil(self, "doneWithInterrupt")
	}
end