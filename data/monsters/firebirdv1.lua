local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Animate = require "actions/Animate"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Action = require "actions/Action"
local PlayAudio = require "actions/PlayAudio"
local YieldUntil = require "actions/YieldUntil"
local Try = require "actions/Try"
local BouncyText = require "actions/BouncyText"

local SpriteNode = require "object/SpriteNode"
local BattleActor = require "object/BattleActor"

local Transform = require "util/Transform"

local PressX = require "data/battle/actions/PressX"
local OnHitEvent = require "data/battle/actions/OnHitEvent"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local Smack = require "data/monsters/actions/Smack"

return {
	name = "Firebird 1.0",
	altName = "Firebird 1.0",
	sprite = "sprites/phantomstandin",

	mockSprite = "sprites/firebirdv1_head",
	mockSpriteOffset = Transform(150, -300),

	stats = {
		xp = 50,
		maxhp = 3000,
		attack = 30,
		defense = 30,
		speed = 2,
		focus = 1,
		luck = 1,
	},

	boss = true,

	run_chance = 0.2,

	coin = 0,

	drops = {},

	scan = "Nah.",

	onAttack = function (self, attacker)
		if self.hp <= 0 then
			return Action()
		end

		
	end,

	onInit = function (self)
		local x = self.sprite.transform.x
		local y = self.sprite.transform.y
		-- Spawn body sprite and end tail sprite
		self.body = SpriteNode(self.scene, Transform(x - 300, y - 300, 2, 2), nil, "firebirdv1", nil, nil, "sprites")
		self.endTail = SpriteNode(self.scene, Transform(x - 50, y + 20, 2, 2), nil, "firebirdv1_piece", nil, nil, "sprites")
		self.endTail:setAnimation("endtail")

		--[[ Spawn neck/tail sprites between body and head/end tail
		self.neck = {}
		for i=0,4 do
			local neckPiece = SpriteNode(self.scene, Transform(x + 390 + i*20, y - 60 - i*10, 2, 2), nil, "firebirdv1_piece", nil, nil, "sprites")
			neckPiece:setAnimation("piece")
			table.insert(self.neck, neckPiece)
		end

		self.tail = {}
		for i=0,4 do
			local tailPiece = SpriteNode(self.scene, Transform(x - 10 - i*10, y + 20, 2, 2), nil, "firebirdv1_piece", nil, nil, "sprites")
			tailPiece:setAnimation("piece")
			table.insert(self.tail, tailPiece)
		end]]
		
		self.sprite.transform.x = self.sprite.transform.x + 250
		self.sprite.transform.y = self.sprite.transform.y - 170

		self.state = "ice"
		self.charge = 0
	end,

	onUpdate = function (self, dt)
		
	end,

	behavior = function (self, target)
		-- Starting state, setup
		if self.state == "fire" then
			if self.charge == 3 then
				return Serial {
					Telegraph(self, "Napalm", {255,255,255,50}),
					Animate(self:getSprite(), "fire_attack"),
					Wait(2),
					Do(function()
						self.charge = 0
						self.state = "ice"
						self:getSprite():setAnimation("ice_idle")
					end)
				}
			end
			self.charge = self.charge + 1
			return Serial {
				Telegraph(self, "Charging "..tostring(4 - self.charge).."...", {255,255,255,50}),
				Animate(self:getSprite(), "fire_charge"..tostring(self.charge))
			}
		elseif self.state == "ice" then
		    if self.charge == 3 then
				return Serial {
					Telegraph(self, "Iceblast", {255,255,255,50}),
					Animate(self:getSprite(), "ice_attack"),
					Wait(2),
					Do(function()
						self.charge = 0
						self.state = "fire"
						self:getSprite():setAnimation("fire_idle")
					end)
				}
			end
			self.charge = self.charge + 1
			return Serial {
				Telegraph(self, "Charging "..tostring(4 - self.charge).."...", {255,255,255,50}),
				Animate(self:getSprite(), "ice_charge"..tostring(self.charge))
			}
		end
	end,
}