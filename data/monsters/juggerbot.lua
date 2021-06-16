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
	name = "Juggerbot",
	altName = "Juggerbot",
	sprite = "sprites/juggerbotbody",

	stats = {
		xp    = 100,
		maxhp = 1000,
		attack = 20,
		defense = 50,
		speed = 1,
		focus = 1,
		luck = 1,
	},

	boss = true,
	
	run_chance = 0.2,

	coin = 0,

	drops = {
		--{item = require "data/items/MetallicPlate", count = 6, chance = 1.0},
	},
	
	scan = "Focus damage on Juggerbot's weapons systems.",
	
	skipAnimation = true,

	onPreInit = function(self)
		self.scene.juggerbotbody = self
		self.sprite.sortOrderY = self.sprite.transform.y + self.sprite.h

		-- Spawn body parts
		local parts = {"juggerbothead", "juggerbotrightarm", "juggerbotleftarm"}
		for k,v in pairs(parts) do
			local oppo = self.scene:addMonster(v)
			oppo:onPreInit()
		end
		
		self.sprite.h = self.sprite.h + 10
	end,
	
	behavior = function (self, target)
		-- Initialize battle data
		if not self.turnPhase then
			self.turnPhase = 1
			
			-- Setup plasma beam sprites
			self.beamSpriteStart = SpriteNode(self.scene, Transform(), nil, "plasmabeam", nil, nil, "ui")
			self.beamSpriteStart:setAnimation("left")
			self.beamSpriteStart.transform.ox = 0
			self.beamSpriteStart.transform.oy = self.beamSpriteStart.h/2
			self.beamSpriteStart.transform.sx = 2
			self.beamSpriteStart.transform.sy = 0
			
			self.beamSprite = SpriteNode(self.scene, Transform(), nil, "plasmabeam", nil, nil, "ui")
			self.beamSprite:setAnimation("center")
			self.beamSprite.transform.ox = 0
			self.beamSprite.transform.oy = self.beamSprite.h/2
			self.beamSprite.transform.sx = 20
			self.beamSprite.transform.sy = 0
		end
		
		if self.turnPhase == 1 then
			action = Action()
		-- Second phase of boss:
		-- roar, charge up plasma cannon for three turns, fire (can kill whole party)
		elseif self.turnPhase == 2 then
			local turnIdx = self.turnCount % 4
			-- charge
			if turnIdx == 0 then
				local parts = {
					self.scene.juggerbotbody,
					self.scene.juggerbothead,
					self.scene.juggerbotrightarm
				}
				local moveBackActions = {Animate(self:getSprite(), "cannonright")}
				for _,sp in pairs(parts) do
					table.insert(
						moveBackActions,
						Ease(sp:getSprite().transform, "x", sp:getSprite().transform.x - 8, 1)
					)
				end
			
				action = Serial {
					Parallel(moveBackActions),
					Animate(self:getSprite(), "idlecannonright"),
					PlayAudio("sfx", "lockon", 1.0, true),
					Telegraph(self, "3...", {255,255,255,50}),
				}
			elseif turnIdx == 1 then
				action = Serial {
					PlayAudio("sfx", "lockon", 1.0, true),
					Telegraph(self, "2...", {255,255,255,50}),
				}
			elseif turnIdx == 2 then
				action = Serial {
					PlayAudio("sfx", "lockon", 1.0, true),
					Telegraph(self, "1...", {255,255,255,50}),
				}
			-- plasma cannon
			elseif turnIdx == 3 then
				-- Can interrupt the plasma cannon if you destroy a body part,
				-- including left arm or head.
				
				-- Can delay it if you use Bunnie's grab or Sonic's roundabout
				
				-- Can interrupt plasma cannon with Mine
				
				-- Can survive plasma cannon if you are using a laser shield
				
				local bodySp = self:getSprite()
				self.beamSpriteStart.transform.x = bodySp.transform.x + 30
				self.beamSpriteStart.transform.y = bodySp.transform.y
				self.beamSprite.transform.x = bodySp.transform.x + 100
				self.beamSprite.transform.y = bodySp.transform.y
				
				local hurtActions = {
					Repeat(Serial {
						Ease(bodySp.transform, "x", function() return bodySp.transform.x + 1 end, 20),
						Ease(bodySp.transform, "x", function() return bodySp.transform.x - 1 end, 20),
					}, 30),
				}
				for _,p in pairs(self.scene.party) do
					table.insert(
						hurtActions,
						Serial {
							Do(function()
								if not p.laserShield then
									p.sprite:setAnimation("hurt")
								end
							end),
							Repeat(Serial {
								Ease(p.sprite.transform, "x", function() return p.sprite.transform.x + 1 end, 20),
								Ease(p.sprite.transform, "x", function() return p.sprite.transform.x - 1 end, 20),
							}, 10),
							p:takeDamage({attack = 100, speed = 100, luck = 50})
						}
					)
				end
				
				local parts = {
					self.scene.juggerbotbody,
					self.scene.juggerbothead,
					self.scene.juggerbotrightarm
				}
				local moveForwardActions = {Animate(self:getSprite(), "undocannonright")}
				for _,sp in pairs(parts) do
					table.insert(
						moveForwardActions,
						Ease(sp:getSprite().transform, "x", sp:getSprite().transform.x + 8, 1)
					)
				end
				
				action = Serial {
					Telegraph(self, "Plasma Beam", {255,255,255,50}),
					PlayAudio("sfx", "plasmabeam", 1.0, true),
					Parallel {
						Ease(self.beamSpriteStart.transform, "sy", 2, 3),
						Ease(self.beamSprite.transform, "sy", 2, 3),
					},
					Parallel(hurtActions),
					Parallel {
						Ease(self.beamSpriteStart.transform, "sy", 0, 3),
						Ease(self.beamSprite.transform, "sy", 0, 3)
					},
					Wait(1),
					Parallel(moveForwardActions)
				}
			end

			self.turnCount = self.turnCount + 1
		end
		
		return action
	end,
	
	getBackwardAnim = function(self)
		return "idleright"
	end
}