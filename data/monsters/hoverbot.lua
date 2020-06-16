local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Animate = require "actions/Animate"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Action = require "actions/Action"
local PlayAudio = require "actions/PlayAudio"

local SpriteNode = require "object/SpriteNode"

local Transform = require "util/Transform"

local OnHitEvent = require "data/battle/actions/OnHitEvent"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local Smack = require "data/monsters/actions/Smack"

return {
	name = "Hoverbot",
	altName = "Hoverbot",
	sprite = "sprites/hoverbot",

	stats = {
		xp    = 30,
		maxhp = 1500,
		attack = 40,
		defense = 20,
		speed = 2,
		focus = 1,
		luck = 1,
	},
	
	hasDropShadow = true,

	run_chance = 0.2,

	coin = 0,

	drops = {
		{item = require "data/items/CrystalWater", count = 1, chance = 0.8},
	},
	
	scan = "Don't attack rover when standing.",
	
	onAttack = function (self, attacker)
		if self.hp == 0 then
			return Action()
		end
	
		if self.state == "upright" or self.state == "transition_to_crouched" then
			-- Damage all party members
			local dmgAllPartyMembers = {}
			local _, firstPartyMember = next(self.scene.party)
			local lastPartyMember
			for _, mem in pairs(self.scene.party) do
				table.insert(dmgAllPartyMembers, OnHitEvent(self, mem))
				lastPartyMember = mem
			end

			return Serial {
				Telegraph(self, "Laser Sweep", {255,255,255,50}),
				
				Animate(function()
					local xform = Transform.from(self.sprite.transform)
					xform.x = xform.x + self.sprite.w/2 - 50
					xform.y = xform.y + self.sprite.h/2 - 40
					return SpriteNode(self.scene, xform, nil, "beamfire", nil, nil, "ui"), true
				end, "idle"),
				
				PlayAudio("sfx", "lasersweep", 1.0, true),
				
				Do(function()
					self.beamSprite.transform.x = self.sprite.transform.x + self.sprite.w/2 - 20
					self.beamSprite.transform.y = self.sprite.transform.y + self.sprite.h/2 - 15
					self.beamSprite.transform.angle = -math.pi/6
				end),
				
				Ease(self.beamSprite.transform, "sx", 20.0, 12, "linear"),
				Ease(self.beamSprite.transform, "angle", math.pi/6, 1, "linear"),
				
				-- Hide beam sprite
				Do(function()
					self.beamSprite.transform.sx = 0
					self.beamSprite.transform.angle = 0
				end),
				
				Parallel(dmgAllPartyMembers)
			}
		else
			return Action()
		end
	end,

	behavior = function (self, target)
		-- Starting state, setup
		if self.state == "idle" then
			self.turnsBeforeTransition = 2

			-- Setup beam sprite
			self.beamSprite = SpriteNode(self.scene, Transform(), nil, "botbeam", nil, nil, "ui")
			self.beamSprite.transform.sx = 0
			
			self.state = "crouched"
		end
	
		-- Two modes, crouched and up
		-- If you attack when crouched, you hurt it
		-- If you attack when up, it does sweep
		if self.state == "transition_to_crouched" then
			return Serial {
				Animate(self.sprite, "transition"),
				Animate(self.sprite, "crouched"),
				Do(function()
					self.state = "crouched"
					self.turnsBeforeTransition = 2
				end)
			}
		elseif self.state == "crouched" then
			return Serial {
				Telegraph(self, "Laser", {255,255,255,50}),
				
				Animate(function()
					local xform = Transform.from(self.sprite.transform)
					xform.x = xform.x + self.sprite.w/2 - 50
					xform.y = xform.y + self.sprite.h/2
					return SpriteNode(self.scene, xform, nil, "beamfire", nil, nil, "ui"), true
				end, "idle"),
				
				PlayAudio("sfx", "laser", 1.0, true),
				
				Do(function()
					self.beamSprite.transform.x = self.sprite.transform.x + self.sprite.w/2 - 50
					self.beamSprite.transform.y = self.sprite.transform.y + self.sprite.h/2 + 20
				end),
				
				Parallel {
					Ease(self.beamSprite.transform, "sx", 1.0, 12),
					Serial {
						Parallel {
							Ease(self.beamSprite.transform, "x", target.sprite.transform.x - self.beamSprite.w, 6, "linear"),
							Ease(self.beamSprite.transform, "y", target.sprite.transform.y, 6, "linear")
						},
						Parallel {
							Ease(self.beamSprite.transform, "sx", 0, 12),
							OnHitEvent(self, target, nil, nil, {attackType = "laser"})
						}
					}
				},

				-- Hide beam sprite and update state
				Do(function()
					self.turnsBeforeTransition = self.turnsBeforeTransition - 1
					if self.turnsBeforeTransition == 0 then
						self.state = "transition_to_upright"
					end
				end)
			}
		elseif self.state == "transition_to_upright" then
			return Serial {
				Animate(self.sprite, "transition"),
				Animate(self.sprite, "upright"),
				Do(function()
					self.state = "upright"
				end)
			}
		elseif self.state == "upright" then
			return Serial {
				Telegraph(self, "Rover bot looks poised to attack", {255,255,255,50}),
				Do(function()
					self.state = "transition_to_crouched"
				end)
			}
		end
	end
}