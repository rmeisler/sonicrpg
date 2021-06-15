local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local MessageBox = require "actions/MessageBox"
local Wait = require "actions/Wait"
local Action = require "actions/Action"
local YieldUntil = require "actions/YieldUntil"
local Try = require "actions/Try"
local Action = require "actions/Action"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"
local BouncyText = require "actions/BouncyText"
local Repeat = require "actions/Repeat"
local While = require "actions/While"
local Executor = require "actions/Executor"

local PressX = require "data/battle/actions/PressX"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local Smack = require "data/monsters/actions/Smack"

local Transform = require "util/Transform"

local BattleActor = require "object/BattleActor"
local SpriteNode = require "object/SpriteNode"

return {
	name = "Right Arm",
	altName = "Right Arm",
	sprite = "sprites/juggerbotbody",
	
	mockSprite = "sprites/juggerbotrightarm",
	mockSpriteOffset = Transform(0, 0),

	stats = {
		xp      = 0,
		maxhp   = 500,
		attack  = 1,
		defense = 10,
		speed   = 1,
		focus   = 1,
		luck    = 1,
	},
	
	run_chance = 0.2,

	coin = 0,

	drops = {
		
	},
	
	scan = "Focus damage on Juggerbot's weapons systems.",
	
	skipAnimation = true,

	onPreInit = function(self)
		self.scene.juggerbotrightarm = self
	end,
	
	onInit = function(self)
		-- Relocate arm to proper area of juggerbot body
		local body = self.scene.juggerbotbody
		self.mockSprite.transform.ox = 0
		self.mockSprite.transform.oy = 0
		self.mockSprite.transform.x = body.sprite.transform.x - body.sprite.w - 10
		self.mockSprite.transform.y = body.sprite.transform.y - body.sprite.h + 50
		self.mockSprite.sortOrderY = self.scene.juggerbothead:getSprite().sortOrderY + 100
		
		-- Locate where we want the cursor to be
		self.sprite.transform.x = body.sprite.transform.x - 40
		self.sprite.transform.y = body.sprite.transform.y + 20
		self.sprite.h = self.sprite.h - 20
	end,
	
	behavior = function (self, target)
		if not self.stunSprites then
			-- Setup stun sprites
			self.stunSprites = {}
			for i=1, 15 do
				local sp = SpriteNode(self.scene, Transform(), nil, "stuneffect", nil, nil, "ui")
				sp.transform.ox = sp.w/2
				sp.transform.oy = sp.h/2
				sp.color[4] = 0
				table.insert(self.stunSprites, sp)
			end
		end

		return Serial {
			Telegraph(self.scene.juggerbotrightarm, "Phasic Stun", {255,255,255,50}),
			Do(function()
				local spr = self.scene.juggerbotrightarm:getSprite()
				spr.transform.ox = 32
				spr.transform.oy = 6
				spr.transform.x = spr.transform.x + 64
				spr.transform.y = spr.transform.y + 12
			end),
			Ease(self.scene.juggerbotrightarm:getSprite().transform, "angle", -math.pi/2, 1.3),
			
			PlayAudio("sfx", "stun", 1.0, true),
			Do(function()
				local rightArmSp = self.scene.juggerbotrightarm:getSprite()
				for index,sp in pairs(self.stunSprites) do
					Executor(self.scene):act(Serial {
						Wait(0.1 * index),
						Do(function()
							sp.transform.x = rightArmSp.transform.x + rightArmSp.h*1.5
							sp.transform.y = rightArmSp.transform.y + 16
							sp.transform.sx = 2
							sp.transform.sy = 2
							sp.color[4] = 255
						end),
						Parallel {
							Ease(sp.transform, "sy", 3, 1.5),
							Ease(sp.transform, "x", target.sprite.transform.x - target.sprite.w/2, 1.6),
							Ease(sp.transform, "y", target.sprite.transform.y, 1.6),
							
							Serial {
								Wait(0.3),
								Do(function()
									if target.sprite.selected ~= "hurt" then
										target.sprite:setAnimation("hurt")
										
										local revAction = target.reverseAnimation or Action()
										Executor(self.scene):act(Serial {
											Parallel {
												revAction,
												Repeat(Parallel {
													Serial {
														Ease(target.sprite.color, 1, 512, 8),
														Ease(target.sprite.color, 1, 300, 8)
													},
													Serial {
														Ease(target.sprite.transform, "x", function() return target.sprite.transform.x + 1 end, 20),
														Ease(target.sprite.transform, "x", function() return target.sprite.transform.x - 1 end, 20)
													}
												}, 10)
											},
											Ease(target.sprite.color, 1, 255, 8)
										})
									end
								end)
							}
						},
						Parallel {
							Ease(sp.transform, "sy", 7, 8),
							Ease(sp.color, 4, 0, 4)
						}
					})
				end
			end),

			Wait(1.6),
			Ease(self.scene.juggerbotrightarm:getSprite().transform, "angle", 0, 1.3),
			Do(function()
				local spr = self.scene.juggerbotrightarm:getSprite()
				spr.transform.ox = 0
				spr.transform.oy = 0
				spr.transform.x = spr.transform.x - 64
				spr.transform.y = spr.transform.y - 12
				
				if not target.laserShield then
					target.state = BattleActor.STATE_IMMOBILIZED
					target.turnsImmobilized = 2
					target.sprite:setAnimation("dead")
				end
			end),
			not target.laserShield and Telegraph(target, target.name.." is stunned!", {255,255,255,50})
				or target:takeDamage({attack = 0, defense = 0, miss = true})
		}
	end,
	
	getBackwardAnim = function(self)
		return "idleright"
	end
}