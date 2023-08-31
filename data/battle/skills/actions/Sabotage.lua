local Action = require "actions/Action"
local MessageBox = require "actions/MessageBox"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local Animate = require "actions/Animate"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local PlayAudio = require "actions/PlayAudio"
local Ease = require "actions/Ease"
local Do = require "actions/Do"
local While = require "actions/While"
local YieldUntil = require "actions/YieldUntil"
local Executor = require "actions/Executor"
local Spawn = require "actions/Spawn"

local SpriteNode = require "object/SpriteNode"

local Transform = require "util/Transform"

local Shock = function(self, target)
	return Parallel {
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
	}
end

local KeyTrigger = function(self, key, _, target)
	if key == self.sequence[1] then
		table.remove(self.sequence, 1)
		local sprite = table.remove(self.spriteNodes, 1)
		local sfx = "lockon"
		if next(self.sequence) == nil then
			self.earlyExitHack = true
			self.keycodeSuccess = true
			sfx = "levelup"
		end

		self.scene.audio:stopSfx()
		Executor(self.scene):act(Serial {
			PlayAudio("sfx", sfx, 1.0, true),
			Parallel {
				Ease(sprite.transform, "sx", 3, 5),
				Ease(sprite.transform, "sy", 3, 5),
				Ease(sprite.color, 4, 0, 5),
				Serial {
					Wait(0.2),
					Shock(self, target)
				}
			},
			Do(function()
				sprite:remove()
			end)
		})
	else
		self.scene.audio:playSfx("error", nil, true)
		self.earlyExitHack = true
	end
end


return function(self, target)
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
			Transform.fromoffset(target.sprite.transform, Transform(-64 + (i-1)*32, -target.sprite.h)),
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

	local prevMusic = self.scene.audio:getCurrentMusic()
	return Serial {
		-- Leap forward while attacking
		Animate(self.sprite, "leap"),
		Parallel {
			Ease(self.sprite.transform, "x", self.sprite.transform.x - 200, 5, "linear"),
			Ease(self.sprite.transform, "y", self.sprite.transform.y - 200, 5, "linear")
		},
		Parallel {
			Ease(self.sprite.transform, "x", target.sprite.transform.x + 70, 5, "linear"),
			Ease(self.sprite.transform, "y", target.sprite.transform.y + 40, 5, "linear")
		},
		PlayAudio("sfx", "bang", 1.0, true),
		Animate(self.sprite, "crouchtinker"),
		Wait(0.5),
		MessageBox {
			message="Rotor: Time to hack this sucker!",
			rect=MessageBox.HEADLINER_RECT,
			sfx="clink",
			closeAction=Wait(0.6)
		},
		-- Throw up button sprites, all at once, all transparent
		Parallel(fadeIn),
		
		Do(function()
			self.scene:addHandler("keytriggered", KeyTrigger, self, target)
			self.scene:focus("keytriggered", self) -- HACK, focus past skills + battle menu
			self.scene:focus("keytriggered", self)
			self.scene:focus("keytriggered", self)
		end),
		
		While(
			function() return not self.earlyExitHack end,
			Wait(3),
			Action()
		),
		
		-- Remove temporary keytriggered event
		Do(function()
			self.scene:removeHandler("keytriggered", KeyTrigger, self, target)
			self.scene:unfocus("keytriggered")
			self.scene:unfocus("keytriggered")
			self.scene:unfocus("keytriggered")
			for _,s in pairs(self.spriteNodes) do
				s:remove()
			end

			-- Enter code to reduce either attack, defense, or speed
			local msg = "successfully resisted sabotage..."
			if self.keycodeSuccess then
				local chance = math.random(1, 3)
				if chance == 1 then -- Reduce attack
					msg = "{h attack} power reduced by 50%!"
					target.stats.attack = target.stats.attack - target.stats.attack/2
				elseif chance == 2 then -- Reduce defense
					msg = "{h defense} reduced by 50%!"
					target.stats.defense = target.stats.defense - target.stats.defense/2
				end
			end
			
			self.scene:run {
				Shock(self, target),

				Parallel {
					MessageBox {
						message=target.name.." "..msg,
						rect=MessageBox.HEADLINER_RECT,
						closeAction=Wait(0.6)
					},
					self.keycodeSuccess and
						Spawn(Serial {
							PlayAudio("music", "sallyrally", 1.0),
							PlayAudio("music", prevMusic, 1.0, true, true)
						}) or
						Action()
				},
				
				Do(function()
					self.doneWithHack = true
				end)
			}
		end),
		
		YieldUntil(self, "doneWithHack"),

		-- Leap backward
		Animate(self.sprite, "leap"),
		Parallel {
			Ease(self.sprite.transform, "x", self.sprite.transform.x - 200, 5, "linear"),
			Ease(self.sprite.transform, "y", self.sprite.transform.y - 200, 5, "linear")
		},
		Parallel {
			Ease(self.sprite.transform, "x", self.sprite.transform.x, 5, "linear"),
			Ease(self.sprite.transform, "y", self.sprite.transform.y, 5, "linear")
		},
		Animate(self.sprite, "idle")
	}
end