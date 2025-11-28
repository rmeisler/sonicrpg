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

local Stars = require "data/battle/actions/Stars"
local PressX = require "data/battle/actions/PressX"
local PressZ = require "data/battle/actions/PressZ"
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
		maxhp = 2500,
		attack = 30,
		defense = 50,
		speed = 10,
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

		self.bullet = SpriteNode(
			self.scene,
			Transform(0,0,2,2),
			{255,255,255,0},
			"golemarm",
			nil,
			nil,
			"ui"
		)
		self.bullet.transform.ox = 0
		self.bullet.transform.oy = self.bullet.h/2
		self.bullet.transform.angle = 0
		
		self.targetSprite = SpriteNode(self.scene, Transform(0, 0, 2, 2), nil, "target", nil, nil, "ui")
		self.targetSprite.transform.ox = self.targetSprite.w/2
		self.targetSprite.transform.oy = self.targetSprite.h/2
		self.targetSprite.color[4] = 0

		self.sprite:setAnimation("idle")

		self.states = {
			"defup",
			"laser",
			"laser",
			"rock",
			"rock",
			"laser",
			"laser",
			"heal",
			"rock",
			"rock",
		}
		self.state_counter = 1
		self.max_states = table.count(self.states)
	end,
	
	behavior = function (self, target)
		local state = self.states[self.state_counter]
		self.state_counter = (self.state_counter % self.max_states) + 1
		if state == "laser" and self.scene.partyByName.b.state == self.STATE_DEAD then
			state = "rock"
		end

		if self.state_counter % 2 == 0 then
			-- Bonus turn
			table.insert(self.scene.opponentTurns, self)
		end

		if state == "laser" then
			-- Energy beam target is always B
			if next(self.targetOverrideStack) == nil then
				target = self.scene.partyByName.b
			end
			local dodgeAction = target.defenseEvent and
				target.defenseEvent(self, target) or
				Action()

			return Serial {
				Telegraph(self, "Energy Beam", {500,500,500,50}),
				Animate(self.sprite, "laser"),
				
				Do(function()
					self.targetSprite.transform.x = target.sprite.transform.x
					self.targetSprite.transform.y = target.sprite.transform.y + 10
				end),
				Parallel {
					Ease(self.targetSprite.color, 4, 255, 5),
					Serial {
						PlayAudio("sfx", "lockon", 1.0, true),
						Parallel {
							Ease(self.targetSprite.transform, "sx", 4, 12, "inout"),
							Ease(self.targetSprite.transform, "sy", 4, 12, "inout")
						},
						Parallel {
							Ease(self.targetSprite.transform, "sx", 1.5, 12, "inout"),
							Ease(self.targetSprite.transform, "sy", 1.5, 12, "inout")
						},
						Parallel {
							Ease(self.targetSprite.transform, "sx", 3, 12, "inout"),
							Ease(self.targetSprite.transform, "sy", 3, 12, "inout")
						},
						Parallel {
							Ease(self.targetSprite.transform, "sx", 2, 12, "inout"),
							Ease(self.targetSprite.transform, "sy", 2, 12, "inout")
						},
						
						Ease(self.targetSprite.color, 4, 0, 5),
					}
				},

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
			self.bullet.transform.x = self.sprite.transform.x + 80
			self.bullet.transform.y = self.sprite.transform.y + 20
			
			local finalAction = function(damageGiver, damageTaker, bonus)
				local stats = nil
				if damageGiver then
					stats = table.clone(damageGiver.stats)
					stats.attack = stats.attack * (bonus or 1.0)
				end
				return Serial {
					Do(function()
						self.bullet.color[4] = 0
					end),
					damageTaker and
						damageTaker:takeDamage(stats) or
						Do(function() target.sprite:setAnimation(target.prevAnim or "idle") end),
					Do(function()
						self.sprite:setAnimation("idle")
						if target.state ~= target.STATE_IMMOBILIZED and target.hp > 0 then
							target.sprite:setAnimation("idle")
						end
					end)
				}
			end

			return Serial {
				Telegraph(self, "Pebble Shooter", {500,500,500,50}),
				Animate(self.sprite, "rock"),
				Do(function()
					self.bullet.color[4] = 255
				end),
				Parallel {
					Serial {
						Parallel {
							Ease(self.bullet.transform, "x", target.sprite.transform.x - 30, 4, "linear"),
							Ease(self.bullet.transform, "y", target.sprite.transform.y, 4, "linear")
						},
						Do(function()
							self.bullet.color[4] = 0
						end)
					},

					(target.noCounter or target.id == "b") and finalAction(self, target) or PressX(
						self,
						target,
						Serial {
							Do(function()
								self.bullet.color[4] = 255
							end),
							PlayAudio("sfx", "pressx", 1.0, true),
							-- Tails blocks, bullet pops up, press z to hit back
							Animate(target.sprite, "block"),
							Parallel {
								Serial {
									Ease(self.bullet.transform, "y", function() return self.bullet.transform.y - 200 end, 4, "quad"),
									Ease(self.bullet.transform, "y", function() return self.bullet.transform.y + 200 end, 4, "quad")
								},
								Serial {
									Wait(0.2),
									PressZ(
										self,
										target,
										Serial {
											Parallel {
												Animate(target.sprite, "slap"),
												Serial {
													Wait(0.1),
													PlayAudio("sfx", "poptop", 1.0, true)
												},
												Ease(self.bullet.transform, "x", self.sprite.transform.x, 4, "quad"),
												Ease(self.bullet.transform, "y", self.sprite.transform.y, 4, "quad")
											},
											Do(function()
												self.bullet.color[4] = 0
											end),
											Parallel {
												Stars(target, self),
												finalAction(self, self, 1.5)
											}
										},
										finalAction()
									)
								}
							}
						},
						finalAction(self, target)
					)
				},
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
				table.insert(dmgAllPartyMembers, mem:takeDamage(self.stats, true, BattleActor.shockKnockback))
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
					self:popStats()
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