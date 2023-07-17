local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Repeat = require "actions/Repeat"
local Animate = require "actions/Animate"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Action = require "actions/Action"
local PlayAudio = require "actions/PlayAudio"
local YieldUntil = require "actions/YieldUntil"
local Try = require "actions/Try"
local BouncyText = require "actions/BouncyText"
local Executor = require "actions/Executor"

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
		speed = 5,
		focus = 1,
		luck = 1,
	},

	boss = true,

	run_chance = 0.2,

	coin = 0,

	drops = {},

	scan = "Nah.",

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

	behavior = function (self, target)
		-- Starting state, setup
		if self.state == "fire" then
			if self.charge == 3 then
				local sprite = self:getSprite()
				local origTargetXform = target.sprite.transform
				local headXformOffset
				if target.playerSlot == 1 then
					headXformOffset = Transform(50, 50)
				elseif target.playerSlot == 2 then
					headXformOffset = Transform(0, 80)
				elseif target.playerSlot == 3 then
					headXformOffset = Transform(-50, 110)
				end
				return Serial {
					Telegraph(self, "Napalm", {255,255,255,50}),
					Parallel {
						Ease(sprite.transform, "x", sprite.transform.x + headXformOffset.x, 2),
						Ease(sprite.transform, "y", sprite.transform.y + headXformOffset.y, 2)
					},
					Animate(self:getSprite(), "fire_attack"),
					Wait(0.5),
					Parallel {
						Serial {
							Wait(2),
							target:takeDamage({attack = 100, speed = 100, luck = 0}),
							Wait(1),
						},
						Repeat(Serial {
							Do(function()
								local xform = sprite.transform
								local targetXForm = target.sprite.transform
								local fireball = SpriteNode(self.scene, Transform(xform.x + 200, xform.y + 120, 4, 4), nil, "fireball", nil, nil, "sprites")
								Executor(self.scene):act(Serial {
									Parallel {
										Ease(fireball.transform, "x", target.sprite.transform.x, 2, "linear"),
										Ease(fireball.transform, "y", target.sprite.transform.y, 2, "linear")
									},
									Animate(target.sprite, "hurt"),
									Ease(target.sprite.transform, "x", targetXForm.x + 5, 30, "quad"),
									Do(function()
										fireball:remove()
									end),
									Ease(target.sprite.transform, "x", targetXForm.x, 30, "quad"),
									Do(function()
										-- noop
									end)
								})
							end),
							Wait(0.05),
						}, 50)
					},
					Parallel {
						Ease(sprite.transform, "x", sprite.transform.x, 2),
						Ease(sprite.transform, "y", sprite.transform.y, 2),
						Ease(target.sprite.transform, "x", origTargetXform.x, 2),
						Ease(target.sprite.transform, "y", origTargetXform.y, 2)
					},
					Do(function()
						if target.hp > 0 then
							target.sprite:setAnimation("idle")
						else
							target.sprite:setAnimation("dead")
						end
						self.charge = 0
						self.state = "ice"
						self:getSprite():pushOverride("idle", "ice_idle")
						self:getSprite():pushOverride("hurt", "ice_hurt")
						self:getSprite():setAnimation("idle")
					end)
				}
			end
			self.charge = self.charge + 1
			return Serial {
				Do(function() self:getSprite():setAnimation("fire_charge"..tostring(self.charge)) end),
				Parallel {
					Telegraph(self, "Charging "..tostring(4 - self.charge).."...", {255,255,255,50}),

					Serial {
						Parallel {
							Ease(self:getSprite().transform, "x", self:getSprite().transform.x + 20, 2),
							Ease(self:getSprite().transform, "y", self:getSprite().transform.y + 10, 2)
						},
						Parallel {
							Ease(self:getSprite().transform, "x", self:getSprite().transform.x, 2),
							Ease(self:getSprite().transform, "y", self:getSprite().transform.y, 2)
						}
					},
				}
			}
		elseif self.state == "ice" then
		    if self.charge == 3 then
				local sprite = self:getSprite()
				local origTargetXform = target.sprite.transform
				local headXformOffset
				if target.playerSlot == 1 then
					headXformOffset = Transform(50, 50)
				elseif target.playerSlot == 2 then
					headXformOffset = Transform(0, 80)
				elseif target.playerSlot == 3 then
					headXformOffset = Transform(-50, 110)
				end
				return Serial {
					Telegraph(self, "Iceblast", {255,255,255,50}),
					Parallel {
						Ease(sprite.transform, "x", sprite.transform.x + headXformOffset.x, 2),
						Ease(sprite.transform, "y", sprite.transform.y + headXformOffset.y, 2)
					},
					Animate(self:getSprite(), "ice_attack"),
					Parallel {
						Serial {
							Wait(0.5),
							Animate(target.sprite, "cold")
						},
						Repeat(Serial {
							Do(function()
								local xform = sprite.transform
								local targetXForm = target.sprite.transform
								local freezepoof = SpriteNode(self.scene, Transform(xform.x + 180, xform.y + 120, 4, 4), nil, "freezepoof", nil, nil, "sprites")
								Executor(self.scene):act(Serial {
									Parallel {
										Ease(freezepoof.transform, "x", target.sprite.transform.x, 2, "linear"),
										Ease(freezepoof.transform, "y", target.sprite.transform.y, 2, "linear")
									},
									Ease(target.sprite.transform, "x", targetXForm.x + 5, 30, "quad"),
									Do(function()
										freezepoof:remove()
									end),
									Ease(target.sprite.transform, "x", targetXForm.x, 30, "quad"),
									Do(function()
										-- noop
									end)
								})
							end),
							Wait(0.05),
						}, 30)
					},
					PlayAudio("sfx", "slice", 0.5, true),
					Animate(target.sprite, "frozen"),
					Repeat(Serial {
						Do(function()
							local xform = sprite.transform
							local targetXForm = target.sprite.transform
							local freezepoof = SpriteNode(self.scene, Transform(xform.x + 180, xform.y + 120, 4, 4), nil, "freezepoof", nil, nil, "sprites")
							Executor(self.scene):act(Serial {
								Parallel {
									Ease(freezepoof.transform, "x", target.sprite.transform.x, 2, "linear"),
									Ease(freezepoof.transform, "y", target.sprite.transform.y, 2, "linear")
								},
								Ease(target.sprite.transform, "x", targetXForm.x + 5, 30, "quad"),
								Do(function()
									freezepoof:remove()
								end),
								Ease(target.sprite.transform, "x", targetXForm.x, 30, "quad"),
								Do(function()
									-- noop
								end)
							})
						end),
						Wait(0.05),
					}, 20),
					Parallel {
						Ease(sprite.transform, "x", sprite.transform.x, 2),
						Ease(sprite.transform, "y", sprite.transform.y, 2),
						Ease(target.sprite.transform, "x", origTargetXform.x, 2),
						Ease(target.sprite.transform, "y", origTargetXform.y, 2)
					},
					Do(function()
						target.state = BattleActor.STATE_IMMOBILIZED
						target.turnsImmobilized = 2

						self.charge = 0
						self.state = "fire"
						self:getSprite():pushOverride("idle", "fire_idle")
						self:getSprite():pushOverride("hurt", "fire_hurt")
						self:getSprite():setAnimation("idle")
					end)
				}
			end
			self.charge = self.charge + 1
			return Serial {
				Do(function() self:getSprite():setAnimation("ice_charge"..tostring(self.charge)) end),
				Parallel {
					Telegraph(self, "Charging "..tostring(4 - self.charge).."...", {255,255,255,50}),

					Serial {
						Parallel {
							Ease(self:getSprite().transform, "x", self:getSprite().transform.x + 20, 2),
							Ease(self:getSprite().transform, "y", self:getSprite().transform.y + 10, 2)
						},
						Parallel {
							Ease(self:getSprite().transform, "x", self:getSprite().transform.x, 2),
							Ease(self:getSprite().transform, "y", self:getSprite().transform.y, 2)
						}
					},
				}
			}
		end
	end
}