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
local Executor = require "actions/Executor"
local Repeat = require "actions/Repeat"
local While = require "actions/While"

local PressX = require "data/battle/actions/PressX"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local Smack = require "data/monsters/actions/Smack"

local Transform = require "util/Transform"
local ItemType = require "util/ItemType"
local TargetType = require "util/TargetType"

local BattleActor = require "object/BattleActor"

return {
	name = "Phantom",
	altName = "Phantom",
	sprite = "sprites/phantomstandin",
	
	mockSprite = "sprites/phantom",
	mockSpriteOffset = Transform(-120, -84),

	insult = "creepo",
	
	hpBarOffset = Transform(100, 0),

	stats = {
		xp    = 20,
		maxhp = 600,
		attack = 40,
		defense = 15,
		speed = 20,
		focus = 1,
		luck = 1,
	},

	run_chance = 0.7,

	coin = 0,

	drops = {
		{item = require "data/items/Mushroom", count = 1, chance = 0.2},
		{item = require "data/items/Mushroom", count = 1, chance = 0.2},
	},

	behavior = function (self, target)
		local stateOverride = nil
		local introAction = Action()
		if not GameState:isFlagSet("ep3_phantom") then
			stateOverride = "scare"
			GameState:setFlag("ep3_phantom")
			introAction = Serial {
				PlayAudio("sfx", "antoinescared", 1.0, true),
				Do(function()
					-- Shock and surprise
					for _,mem in pairs(target.scene.party) do
						if mem.state ~= BattleActor.STATE_DEAD then
							mem.sprite:setAnimation("shock")
						end
					end
				end),
				Wait(2),
				Do(function()
					target.scene.partyByName.antoine.sprite:setAnimation("nervous")
				end),
				MessageBox{message="Antoine: W-W-W-What is that!?"},
				Do(function()
					target.scene.partyByName.sally.sprite:setAnimation("thinking")
				end),
				MessageBox{message="Sally: I-I don't know!{p60} It doesn't look robotic?..."},
				Do(function()
					target.scene.partyByName.sonic.sprite:setAnimation("takenback")
				end),
				MessageBox{message="Sonic: Whatever it is, it sure is ugly..."},
				Do(function()
					target.scene.partyByName.antoine.sprite:setAnimation("idle")
					target.scene.partyByName.sally.sprite:setAnimation("idle")
					target.scene.partyByName.sonic.sprite:setAnimation("idle")
				end)
			}
		end
	
		local state
		
		if stateOverride then
			state = stateOverride
		else
			local stateOdds = math.random(100)
			if stateOdds < 3 then
				state = "disappear"
			elseif stateOdds < 30 then
				state = "scare"
			elseif stateOdds < 70 then
				state = "claw"
			elseif stateOdds <= 100 then
				state = "poisonclaw"
			end
		end

		local selfSp = self:getSprite()
		local selfXform = selfSp.transform
		local targetSp = target:getSprite()
		local targetXform = targetSp.transform
		if state == "disappear" then
			return Serial {
				Telegraph(self, "Disappear", {255,255,255,50}),
				PlayAudio("sfx", "oppdeath", 1.0, true),
				Ease(self:getSprite().color, 4, 0, 1),
				Do(function()
					self.dropShadow:remove()
					selfSp:remove()
					self.state = self.STATE_DEAD
				end)
			}
		elseif state == "scare" then
			local abilities = {"attack", "use skills", "use items"}
			if self.scene.removedOption then
				for idx, opt in pairs(abilities) do
					if opt == self.scene.removedOption then
						table.remove(abilities, idx)
						break
					end
				end
			end
			local ability = abilities[math.random(#abilities)]
			local scareActions = {Animate(self:getSprite(), "scare")}
			self.scene.removedOption = ability
			if ability == "attack" then
				for _,mem in pairs(target.scene.party) do
					if mem.state ~= BattleActor.STATE_DEAD then
						mem.options = table.clone(mem.origOptions)
						table.remove(mem.options, 1)
						table.insert(
							scareActions,
							Serial {
								Do(function() mem.sprite:setAnimation("shock") end),
								Wait(2),
								Do(function() mem.sprite:setAnimation("idle") end)
							}
						)
					end
				end
			elseif ability == "use skills" then
				for _,mem in pairs(target.scene.party) do
					if mem.state ~= BattleActor.STATE_DEAD then
						mem.options = table.clone(mem.origOptions)
						table.remove(mem.options, 2)
						table.insert(
							scareActions,
							Serial {
								Do(function() mem.sprite:setAnimation("shock") end),
								Wait(2),
								Do(function() mem.sprite:setAnimation("idle") end)
							}
						)
					end
				end
			elseif ability == "use items" then
				for _,mem in pairs(target.scene.party) do
					if mem.state ~= BattleActor.STATE_DEAD then
						mem.options = table.clone(mem.origOptions)
						table.remove(mem.options, 3)
						table.insert(
							scareActions,
							Serial {
								Do(function() mem.sprite:setAnimation("shock") end),
								Wait(2),
								Do(function() mem.sprite:setAnimation("idle") end)
							}
						)
					end
				end
			end
			return Serial {
				introAction,
				Telegraph(self, "Scare", {255,255,255,50}),
				PlayAudio("sfx", "antoinescared", 1.0, true),
				Parallel(scareActions),
				Do(function() self:getSprite():setAnimation("idle") end),
				MessageBox {message="Party lost the ability to "..ability.."!", rect=MessageBox.HEADLINER_RECT, closeAction=Wait(0.6)},
			}
		elseif state == "claw" then
			local dmgAction = Serial {
				Wait(0.4),
				target:takeDamage(self.stats, true)
			}
			if target.id == "sonic" and target.state == target.STATE_IDLE then
				dmgAction = PressX(
					self,
					target,
					Serial {
						PlayAudio("sfx", "pressx", 1.0, true),
						Parallel {
							Serial {
								Animate(target.sprite, "leap_dodge"),
								Ease(target.sprite.transform, "y", target.sprite.transform.y - target.sprite.h*2, 8, "linear"),
								Ease(target.sprite.transform, "y", target.sprite.transform.y, 6, "quad"),
								Animate(target.sprite, "crouch"),
								Wait(0.1),
								Animate(target.sprite, "victory"),
								Wait(0.8),
								Animate(target.sprite, "idle"),
							},
							BouncyText(
								Transform(
									target.sprite.transform.x + 10 + (target.textOffset.x),
									target.sprite.transform.y + (target.textOffset.y)),
								{255,255,255,255},
								FontCache.ConsolasLarge,
								"miss",
								6,
								false,
								true -- outline
							),
						}
					},
					dmgAction
				)
			end
			return Serial {
				Telegraph(self, "Claw", {255,255,255,50}),
				Animate(selfSp, "spawn_arm"),
				Do(function() selfSp:setAnimation("arm_idle") end),
				Wait(1),
				(self ~= target and
					Parallel {
						Ease(selfXform, "x",
							function()
								return targetXform.x - selfSp.w*2 - target.sprite.w/2
							end,
							2
						),
						Ease(selfXform, "y",
							function()
								return targetXform.y - selfSp.h*2 + target.sprite.h
							end,
							2
						)
					} or Action()),
				Parallel {
					Serial {
						Wait(0.4),
						PlayAudio("sfx", "slash", 1.0, true),
						Animate(selfSp, "slash")
					},
					dmgAction
				},
				Do(function() selfSp:setAnimation("idle") end),
				Parallel {
					Ease(selfXform, "x", selfXform.x, 1),
					Ease(selfXform, "y", selfXform.y, 1)
				}
			}
		elseif state == "poisonclaw" then
			local dmgAction = Serial {
				Wait(0.4),
				target:takeDamage(self.stats, true),
				Do(function()
					-- Can't poison someone wearing Copper Amulet
					if target.side == TargetType.Party and
					   GameState:isEquipped(target.id, ItemType.Accessory, "Copper Amulet")
					then
						return
					end

					target.poisoned = table.clone(self.stats)
					target.poisoned.attack = target.poisoned.attack / 2
					target.poisoned.nonlethal = true

					-- Always fade in and out green
					target.poisonAnim = Executor(target.scene)
					target.poisonAnim:act(While(
						function()
							return target.poisoned
						end,
						Repeat(Serial {
							Ease(targetSp.color, 2, 400, 1.5),
							Ease(targetSp.color, 2, 300, 1.5)
						}),
						Ease(target.color, 2, 255, 1)
					))
				end)
			}
			if target.id == "sonic" and target.state == target.STATE_IDLE then
				dmgAction = PressX(
					self,
					target,
					Serial {
						PlayAudio("sfx", "pressx", 1.0, true),
						Parallel {
							Serial {
								Animate(target.sprite, "leap_dodge"),
								Ease(target.sprite.transform, "y", target.sprite.transform.y - target.sprite.h*2, 8, "linear"),
								Ease(target.sprite.transform, "y", target.sprite.transform.y, 6, "quad"),
								Animate(target.sprite, "crouch"),
								Wait(0.1),
								Animate(target.sprite, "victory"),
								Wait(0.8),
								Animate(target.sprite, "idle"),
							},
							BouncyText(
								Transform(
									target.sprite.transform.x + 10 + (target.textOffset.x),
									target.sprite.transform.y + (target.textOffset.y)),
								{255,255,255,255},
								FontCache.ConsolasLarge,
								"miss",
								6,
								false,
								true -- outline
							),
						}
					},
					dmgAction
				)
			end
			
			return Serial {
				Telegraph(self, "Poison Claw", {255,255,255,50}),
				Animate(selfSp, "spawn_arm"),
				Do(function() selfSp:setAnimation("arm_idle") end),
				Wait(1),
				(self ~= target and
					Parallel {
						Ease(selfXform, "x",
							function()
								return targetXform.x - selfSp.w*2 - target.sprite.w/2
							end,
							2
						),
						Ease(selfXform, "y",
							function()
								return targetXform.y - selfSp.h*2 + target.sprite.h
							end,
							2
						)
					} or Action()),
				Parallel {
					Serial {
						Wait(0.4),
						PlayAudio("sfx", "slash", 1.0, true),
						Animate(selfSp, "slash")
					},
					dmgAction
				},
				Do(function() selfSp:setAnimation("idle") end),
				Parallel {
					Ease(selfXform, "x", selfXform.x, 1),
					Ease(selfXform, "y", selfXform.y, 1)
				}
			}
		end
	end,
	
	scan = "Scan has affected Phantom's phase shifting!"
}