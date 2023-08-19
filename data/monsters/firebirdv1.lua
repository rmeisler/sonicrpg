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
local Spawn = require "actions/Spawn"
local MessageBox = require "actions/MessageBox"

local SpriteNode = require "object/SpriteNode"
local BattleActor = require "object/BattleActor"

local Transform = require "util/Transform"

local PressX = require "data/battle/actions/PressX"
local PressZ = require "data/battle/actions/PressZ"
local OnHitEvent = require "data/battle/actions/OnHitEvent"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local Smack = require "data/monsters/actions/Smack"

return {
	name = "Project Firebird",
	altName = "Project Firebird",
	sprite = "sprites/phantomstandin",

	mockSprite = "sprites/projectfirebird",
	mockSpriteOffset = Transform(-230, -280),

	hpBarOffset = Transform(500, 200),

	stats = {
		xp = 120,
		maxhp = 10, --4000,
		attack = 60,
		defense = 30,
		speed = 5,
		focus = 1,
		luck = 1,
	},

	boss = true,

	run_chance = 0.2,

	coin = 0,

	drops = {},

	scan = "{h Laser Shields} might be a good idea...",

	onInit = function (self)
		-- Override death to not do explosion/disappear animation
		self.die = function(_)
			GameState:setFlag("ep4_beat_firebird")
			local sprite = self:getSprite()
			return Parallel {
				Repeat(Serial {
					Ease(sprite.transform, "x", function() return sprite.transform.x + 1 end, 20),
					Ease(sprite.transform, "x", function() return sprite.transform.x - 1 end, 20)
				}),
				Serial {
					Repeat(Serial {
						PlayAudio("sfx", "explosion", 1.0, true),
						Animate(function()
							local xform = Transform.from(sprite.transform) 
							return SpriteNode(self.scene, Transform(xform.x + 300, xform.y + 100, 2, 2), nil, "explosion", nil, nil, "ui"), true
						end, "explode"),
						PlayAudio("sfx", "explosion", 1.0, true),
						Animate(function()
							local xform = Transform.from(sprite.transform) 
							return SpriteNode(self.scene, Transform(xform.x + 250, xform.y + 200, 2, 2), nil, "explosion", nil, nil, "ui"), true
						end, "explode"),
						PlayAudio("sfx", "explosion", 1.0, true),
						Animate(function()
							local xform = Transform.from(sprite.transform) 
							return SpriteNode(self.scene, Transform(xform.x + 150, xform.y + 150, 2, 2), nil, "explosion", nil, nil, "ui"), true
						end, "explode")
					}, 3),
					Parallel {
						Repeat(Serial {
							Parallel {
								Animate(function()
									local xform = Transform(sprite.transform.x + 300, sprite.transform.y + 100, 2, 2)
									return SpriteNode(self.scene, xform, nil, "lightning", nil, nil, "ui"), true
								end, "idle"),
								Serial {
									Wait(0.2),
									PlayAudio("sfx", "shocked", 0.5, true),
								}
							},
							Parallel {
								Animate(function()
									local xform = Transform(sprite.transform.x + 150, sprite.transform.y + 200, 2, 2)
									return SpriteNode(self.scene, xform, nil, "lightning", nil, nil, "ui"), true
								end, "idle"),
								Serial {
									Wait(0.2),
									PlayAudio("sfx", "shocked", 0.5, true),
								}
							},
							Parallel {
								Animate(function()
									local xform = Transform(sprite.transform.x + 250, sprite.transform.y + 150, 2, 2)
									return SpriteNode(self.scene, xform, nil, "lightning", nil, nil, "ui"), true
								end, "idle"),
								Serial {
									Wait(0.2),
									PlayAudio("sfx", "shocked", 0.5, true),
								}
							}
						}),
						Serial {
							MessageBox {message="Project Firebird is disabled!", rect=MessageBox.HEADLINER_RECT},
							Do(function() self.scene.sceneMgr:popScene{} end)
						}
					}
				}
			}
		end

		-- Setup plasma beam sprites
		self.beamSpriteStart = SpriteNode(self.scene, Transform(), nil, "plasmabeam", nil, nil, "ui")
		self.beamSpriteStart:setAnimation("center")
		self.beamSpriteStart.transform.ox = 0
		self.beamSpriteStart.transform.oy = self.beamSpriteStart.h/2
		self.beamSpriteStart.transform.angle = math.pi/2
		self.beamSpriteStart.transform.sx = 5
		self.beamSpriteStart.transform.sy = 0

		self.beamSprite = SpriteNode(self.scene, Transform(), nil, "plasmabeam", nil, nil, "ui")
		self.beamSprite:setAnimation("ground")
		self.beamSprite.transform.ox = 0
		self.beamSprite.transform.oy = self.beamSprite.h/2
		self.beamSprite.transform.angle = math.pi/2
		self.beamSprite.transform.sx = 5
		self.beamSprite.transform.sy = 0

		self.state = "ice"
		self.sprite.transform.x = self.sprite.transform.x + 60
		self.sprite.transform.y = self.sprite.transform.y - 50
	end,

	behavior = function (self, target)
		local sprite = self:getSprite()
		if self.state == "pause_to_ice" then
			-- 50% chance of shifting to ice or fly
			if math.random() < 0.5 then
				self.state = "ice"
			else
				self.state = "fly"
			end
			local transitionSp = SpriteNode(
			    self.scene,
				Transform.from(self:getSprite().transform, Transform(-32, 32)),
				nil,
				"projectfirebird",
				nil,
				nil,
				"sprites")
			transitionSp:setAnimation("fireconvert")
			self:getSprite():setAnimation("convert")
			self:getSprite():popOverride("idle")
			self:getSprite():popOverride("hurt")
			return Serial {
				-- Fade to fire animation...
				Ease(transitionSp.color, 4, 0, 1),
				Do(function()
					transitionSp:remove()
					self:getSprite():setAnimation("idle")
				end)
			}
		elseif self.state == "pause_to_fire" then
			-- 50% chance of shifting to fire or fly
			if math.random() < 0.5 then
				self.state = "fire"
			else
				self.state = "fly"
			end
			local transitionSp = SpriteNode(
			    self.scene,
				Transform.from(self:getSprite().transform, Transform(-32, 32)),
				nil,
				"projectfirebird",
				nil,
				nil,
				"sprites")
			transitionSp:setAnimation("iceconvert")
			self:getSprite():setAnimation("convert")
			self:getSprite():popOverride("idle")
			self:getSprite():popOverride("hurt")
			return Serial {
				-- Fade to fire animation...
				Ease(transitionSp.color, 4, 0, 1),
				Do(function()
					transitionSp:remove()
					self:getSprite():setAnimation("idle")
				end)
			}
		elseif self.state == "fly" then
			self.untargetable = true
			self.state = "skybeam"
			self.origXForm = Transform.from(sprite.transform)
			return Serial {
				Telegraph(self, "Take Off", {255,255,255,50}),
				Animate(sprite, "fly"),
				-- screen jitter
				self.scene:screenShake(10, 30, 20),
				PlayAudio("sfx", "griffvehicle2", 1.0, true),
				Parallel {
					Ease(sprite.transform, "x", 900, 3, "inout"),
					Ease(sprite.transform, "y", function() return sprite.transform.y - 200 end, 3, "inout"),
					Ease(sprite.transform, "angle", -math.pi/10, 5)
				}
			}
		elseif self.state == "skybeam" then
			self.state = "flyback"
			return Serial {
				Telegraph(self, "Sky Beam", {255,255,255,50}),
				Do(function()
					-- Start beamsprite back where it belongs
					self.beamSpriteStart.transform.x = 700
					self.beamSpriteStart.transform.y = 0
					self.beamSprite.transform.x = 700
					self.beamSprite.transform.y = self.beamSpriteStart.transform.y + self.beamSpriteStart.h*4
				end),
				Parallel {
					Ease(self.beamSpriteStart.transform, "sy", 5, 3),
					Ease(self.beamSprite.transform, "sy", 5, 3),
				},
				PressZ(
					self,
					target,
					Serial {
						PlayAudio("sfx", "pressx", 1.0, true),
						target:takeDamage({miss = true, attack = 1, speed = 1, luck = 1})
					},
					target:takeDamage(self.stats)
				),
				Parallel {
					Ease(self.beamSpriteStart.transform, "x", -100, 1),
					Ease(self.beamSprite.transform, "x", -100, 1),
				},
				Parallel {
					Ease(self.beamSpriteStart.transform, "sy", 0, 3),
					Ease(self.beamSprite.transform, "sy", 0, 3)
				},
				Wait(1),
				Do(function()
					-- Start beamsprite back where it belongs
					self.beamSpriteStart.transform.x = 100
					self.beamSpriteStart.transform.y = 0
					self.beamSprite.transform.x = 100
					self.beamSprite.transform.y = self.beamSpriteStart.transform.y + self.beamSpriteStart.h*4
				end),
				Parallel {
					Ease(self.beamSpriteStart.transform, "sy", 5, 3),
					Ease(self.beamSprite.transform, "sy", 5, 3),
				},
				Parallel {
					Ease(self.beamSpriteStart.transform, "x", 900, 1),
					Ease(self.beamSprite.transform, "x", 900, 1),
					Serial {
						Wait(0.2),
						PressZ(
							self,
							target,
							Serial {
								PlayAudio("sfx", "pressx", 1.0, true),
								target:takeDamage({miss = true, attack = 1, speed = 1, luck = 1})
							},
							target:takeDamage(self.stats)
						)
					}
				},
				Parallel {
					Ease(self.beamSpriteStart.transform, "sy", 0, 3),
					Ease(self.beamSprite.transform, "sy", 0, 3)
				}
			}
		elseif self.state == "flyback" then
			-- 50% chance of fire or ice
			if math.random() < 0.5 then
				self.state = "fire"
			else
				self.state = "ice"
			end
			self.untargetable = false
			sprite.transform.x = -900
			sprite.transform.y = self.origXForm.y
			return Serial {
				PlayAudio("sfx", "griffvehicle", 1.0, true),
				Parallel {
					Ease(sprite.transform, "x", self.origXForm.x, 2, "inout"),
					Ease(sprite.transform, "angle", 0, 5)
				},
				PlayAudio("sfx", "cyclopsstep", 1.0, true),
				self.scene:screenShake(20, 30, 1),
				Wait(1),
				Do(function()
					sprite:setAnimation("idle")
				end)
			}
		elseif self.state == "fire" then
			local origTargetXform = target.sprite.transform
			local transitionSp = SpriteNode(
			    self.scene,
				Transform.from(self:getSprite().transform, Transform(-32, 32)),
				nil,
				"projectfirebird",
				nil,
				nil,
				"sprites")
			transitionSp:setAnimation("convert")
			self:getSprite():setAnimation("fireconvert")
			return Serial {
				-- Fade to fire animation...
				Ease(transitionSp.color, 4, 0, 1),
				Do(function()
					transitionSp:remove()
				end),
				Telegraph(self, "Napalm", {255,255,255,50}),
				Animate(self:getSprite(), "fireattack"),
				PlayAudio("sfx", "firebirdbreath", 1.0, true),
				Wait(0.5),
				Parallel {
					Serial {
						Wait(2),
						PressZ(
							self,
							target,
							Serial {
								PlayAudio("sfx", "pressx", 1.0, true),
								target:takeDamage({miss = true, attack = 1, speed = 1, luck = 1})
							},
							target:takeDamage({attack = 90, speed = 100, luck = 0})
						),
						Wait(1),
					},
					Repeat(Serial {
						Do(function()
							local xform = sprite.transform
							local targetXForm = target.sprite.transform
							local fireball = SpriteNode(self.scene, Transform(xform.x + sprite.w*2 - 50, xform.y + 200, 4, 4), nil, "fireball", nil, nil, "infront")
							Executor(self.scene):act(Serial {
								Parallel {
									Ease(fireball.transform, "x", target.sprite.transform.x - 20, 2, "linear"),
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
					if target.hp <= 0 then
						target.sprite:setAnimation("dead")
					else
						target.sprite:setAnimation("idle")
					end
					self:getSprite():pushOverride("hurt", "firehurt")
					self:getSprite():pushOverride("idle", "fireidle")
					self:getSprite():setAnimation("idle")
					self.state = "pause_to_ice"
				end)
			}
		elseif self.state == "ice" then
			local origTargetXform = target.sprite.transform
			local transitionSp = SpriteNode(
			    self.scene,
				Transform.from(self:getSprite().transform, Transform(-32, 32)),
				nil,
				"projectfirebird",
				nil,
				nil,
				"sprites")
			transitionSp:setAnimation("convert")
			self:getSprite():setAnimation("iceconvert")
			return Serial {
				-- Fade to fire animation...
				Ease(transitionSp.color, 4, 0, 1),
				Do(function()
					transitionSp:remove()
				end),
				Telegraph(self, "Iceblast", {255,255,255,50}),
				Animate(self:getSprite(), "iceattack"),
				PlayAudio("sfx", "firebirdbreath", 1.0, true),
				Parallel {
					Serial {
						Wait(0.5),
						Animate(target.sprite, "cold")
					},
					Repeat(Serial {
						Do(function()
							local xform = sprite.transform
							local targetXForm = target.sprite.transform
							local freezepoof = SpriteNode(self.scene, Transform(xform.x + sprite.w*2 - 50, xform.y + 200, 4, 4), nil, "freezepoof", nil, nil, "infront")
							Executor(self.scene):act(Serial {
								Parallel {
									Ease(freezepoof.transform, "x", target.sprite.transform.x - 20, 2, "linear"),
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
				Spawn(
					PressZ(
						self,
						target,
						Serial {
							PlayAudio("sfx", "pressx", 1.0, true),
							target:takeDamage(self.stats, false, function(_self, _impact, _direction) return Action() end)
						},
						Serial {
							target:takeDamage(self.stats, false, function(_self, _impact, _direction) return Action() end),
							PlayAudio("sfx", "slice", 0.3, true),
							Animate(target.sprite, "frozen"),
							Do(function()
								target.state = BattleActor.STATE_IMMOBILIZED
								target.turnsImmobilized = 2
								self:getSprite():pushOverride("idle", "iceidle")
								self:getSprite():pushOverride("hurt", "icehurt")
							end)
						}
					)
				),
				Repeat(Serial {
					Do(function()
						local xform = sprite.transform
						local targetXForm = target.sprite.transform
						local freezepoof = SpriteNode(self.scene, Transform(xform.x + sprite.w*2 - 50, xform.y + 200, 4, 4), nil, "freezepoof", nil, nil, "infront")
						Executor(self.scene):act(Serial {
							Parallel {
								Ease(freezepoof.transform, "x", target.sprite.transform.x - 20, 2, "linear"),
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
					self:getSprite():setAnimation("idle")
					self.state = "pause_to_fire"
				end)
			}
		end
	end
}