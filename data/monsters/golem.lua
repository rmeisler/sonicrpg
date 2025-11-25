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
local Repeat = require "actions/Repeat"
local Spawn = require "actions/Spawn"
local MessageBox = require "actions/MessageBox"
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
	name = "Golem",
	altName = "Golem",
	sprite = "sprites/golem",

	stats = {
		xp    = 50,
		maxhp = 1500,
		attack = 20,
		defense = 30,
		speed = 5,
		focus = 50,
		luck = 3,
	},
	
	hurtSfx = "openchasm",
	is_bot = false,
	insult = "rock-face",

	run_chance = 0,

	coin = 0,

	drops = {
		{item = require "data/items/RainbowSyrup", count = 1, chance = 1},
	},

	scan = "",

	onInit = function(self)
		-- Setup beam sprite
		self.beamSprite = SpriteNode(self.scene, Transform(), nil, "botbeam", nil, nil, "ui")
		self.beamSprite.transform.sx = 0
		self.beamSprite.transform.sy = 1
		self.beamSprite.transform.ox = 0

		self.sprite:setAnimation("hide")

		self.states = {
			"reveal",
			"laser",
			"rock",
			"rock",
			"laser-sweep",
			"rock",
			"shell",
			"heal",
			"noop",
			"reveal2",
			"defup"
		}
		self.state_counter = 1
		self.max_states = table.count(self.states)
	end,
	
	behavior = function (self, target)
		local state = self.states[self.state_counter]
		self.state_counter = (self.state_counter % self.max_states) + 1

		if state == "reveal" then
			return Serial {
				Animate(self.sprite, "reveal"),
				Do(function()
					self.sprite:setAnimation("idle")
				end)
			}
		elseif state == "reveal2" then
			return Serial {
				Animate(self.sprite, "reveal"),
				Do(function()
					self:popStats()
					self.sprite:setAnimation("idle")
				end)
			}
		elseif state == "laser" then
			local dodgeAction = target.defenseEvent and
				target.defenseEvent(self, target) or
				Action()

			return Serial {
				Telegraph(self, "Energy Beam", {500,500,500,50}),
				Animate(self.sprite, "laser"),

				Parallel {
					Serial {
						Wait(0.2),
						dodgeAction
					},
					Serial {
						Animate(function()
							local xform = Transform.from(self.sprite.transform)
							xform.x = xform.x - 40
							xform.y = xform.y - 60
							return SpriteNode(self.scene, xform, nil, "beamfire", nil, nil, "ui"), true
						end, "idle"),
						PlayAudio("sfx", "swatbotlaser", 1.0, true),
							
						Do(function()
							self.beamSprite.transform.x = self.sprite.transform.x - 40 + self.beamSprite.w
							self.beamSprite.transform.y = self.sprite.transform.y - 50 + self.beamSprite.h*2
							self.beamSprite.transform.ox = 0
							
							local x1, y1 = self.beamSprite.transform.x, self.beamSprite.transform.y
							local x2, y2 = target.sprite.transform.x, target.sprite.transform.y

							local dx = (x2 - x1)
							local dy = (y2 - y1)

							local dot = dx * dx
							local m1 = math.sqrt(dx*dx + dy*dy)
							local m2 = dx
							local angle = math.acos(dot / (m1 * m2))
							
							if self.beamSprite.transform.y > target.sprite.transform.y then
								self.beamSprite.transform.angle = -angle
							else
								self.beamSprite.transform.angle = angle
							end
							
							self.xDist = dx
							self.yDist = dy
							self.len = m1/self.beamSprite.w	
						end),
						
						-- Beam stretch to target and recede
						Ease(self.beamSprite.transform, "sx", function() return self.len end, 8),
						
						Do(function()
							self.beamSprite.transform.ox = self.beamSprite.w
							
							self.beamSprite.transform.x = self.beamSprite.transform.x + self.xDist
							self.beamSprite.transform.y = self.beamSprite.transform.y + self.yDist
						end),

						Ease(self.beamSprite.transform, "sx", 0, 8),

						Try(
							YieldUntil(
								function()
									return target.dodged
								end
							),
							Do(function()
								target.dodged = false
							end),
							target:takeDamage(self.stats, true, BattleActor.shockKnockback)
						)
					}
				},

				Do(function()
					self.sprite:setAnimation("idle")
				end)
			}
		elseif state == "rock" then
			return Serial {
				Telegraph(self, "Pebble Shooter", {500,500,500,50}),
				Animate(self.sprite, "rock"),
				Do(function()
					self.sprite:setAnimation("idle")
				end)
			}
		elseif state == "laser-sweep" then
			-- Damage all party members
			local dmgAllPartyMembers = {}
			local _, firstPartyMember = next(self.scene.party)
			local lastPartyMember
			for _, mem in pairs(self.scene.party) do
				table.insert(dmgAllPartyMembers, OnHitEvent(self, mem))
				lastPartyMember = mem
			end

			return Serial {
				Telegraph(self, "Energy Beam Sweep", {500,500,500,50}),
				Animate(self.sprite, "glow"),
				Animate(self.sprite, "laser"),
				
				Animate(function()
					local xform = Transform.from(self.sprite.transform)
					xform.x = xform.x - 40
					xform.y = xform.y - 60
					return SpriteNode(self.scene, xform, nil, "beamfire", nil, nil, "ui"), true
				end, "idle"),
				
				PlayAudio("sfx", "lasersweep", 1.0, true),
				
				Do(function()
					self.beamSprite.transform.x = self.sprite.transform.x + self.sprite.w/2 - 40
					self.beamSprite.transform.y = self.sprite.transform.y + self.sprite.h/2 - 60
					self.beamSprite.transform.angle = -math.pi/6
					self.beamSprite.transform.ox = 0
				end),
				
				Ease(self.beamSprite.transform, "sx", 20.0, 12, "linear"),
				Ease(self.beamSprite.transform, "angle", math.pi/6, 1, "linear"),
				
				-- Hide beam sprite
				Do(function()
					self.beamSprite.transform.sx = 0
					self.beamSprite.transform.angle = 0
				end),
				
				Parallel(dmgAllPartyMembers),
				Do(function()
					self.sprite:setAnimation("idle")
				end)
			}
		elseif state == "shell" then
			return Serial {
				Telegraph(self, "Cocoon", {500,500,500,50}),
				Animate(self.sprite, "shell"),
				Do(function()
					self:pushStats({attack = self.stats.attack, defense = 100, speed = self.stats.speed, luck = self.stats.luck})
				end)
			}
		elseif state == "heal" then
			return Serial {
				Telegraph(self, "Revitalize", {500,500,500,50}),
				Heal("hp", math.random(200,400))(self, self)
			}
		elseif state == "noop" then
			return Telegraph(self, "Golem remains still", {500,500,500,50})
		elseif state == "defup" then
			return Serial {
				Telegraph(self, "Defense Up", {500,500,500,50}),
				Animate(self.sprite, "glow"),
				Animate(self.sprite, "defup"),
				Do(function()
					self.sprite:setAnimation("idle")
					self:pushStats({
						attack = self.stats.attack,
						defense = self.stats.defense * 1.5,
						speed = self.stats.speed,
						luck = self.stats.luck
					})
				end),
				MessageBox {
					message=self.name.." defense increased by 50%!",
					rect=MessageBox.HEADLINER_RECT,
					closeAction=Wait(1),
					sfx="stare"
				}
			}
		else
			return Action()
		end
	end
}