local Parallel = require "actions/Parallel"
local Serial = require "actions/Serial"
local PlayAudio = require "actions/PlayAudio"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local Wait = require "actions/Wait"
local Action = require "actions/Action"
local BouncyText = require "actions/BouncyText"
local Do = require "actions/Do"

local PressX = require "data/battle/actions/PressX"

local Transform = require "util/Transform"

local PartyMember = require "object/PartyMember"

-- Respond to attack with defense event, if possible,
-- otherwise target takes damage as normal
return function(self, target, returnAction, knockbackActionFun, details)
	if not returnAction then
		returnAction = Action()
	end
	
	if not details then
		details = {}
	end

	local actions = {}
	if self.istype(PartyMember) and self.attackEvent then
		table.insert(actions, self:attackEvent(target, returnAction, knockbackActionFun))
	end
	if target.istype(PartyMember) and target.defenseEvent then
		table.insert(actions, target.defenseEvent(self, target, returnAction, knockbackActionFun))
	end
	
	-- 20% chance, all else being equal, you will get a chance at a special "x" event
	if  next(actions) == nil and
		self.istype(PartyMember)
		--and (math.random() < 0.4 + (self.stats.luck/100))
	then
		local bonusStats = {
			attack = 1.5 * self.stats.attack,
			speed = self.stats.speed,
			luck = self.stats.luck
		}
		table.insert(
			actions,
			PressX(
				self,
				target,
				Serial {
					Do(function() self.scene.audio:playSfx("gotit", 1.0, false) end),
					target:takeDamage(bonusStats, false, knockbackActionFun)
				},
				target:takeDamage(self.stats, false, knockbackActionFun),
				0.3
			)
		)
		table.insert(actions, returnAction)
	end
	
	-- If target is sonic and attack is a laser, allow dodge
	if  next(actions) == nil and
		target.istype(PartyMember) and
		target.id == "sonic" and
		details.attackType == "laser"
	then
		table.insert(
			actions,
			PressX(
				self,
				target,
				Serial {
					Do(function()
						target.dodged = true
					end),
					PlayAudio("sfx", "pressx", 1.0, true),
					Parallel {
						Serial {
							Animate(target.sprite, "crouch"),
							Wait(0.1),
							Animate(target.sprite, "leap_dodge"),
							Ease(target.sprite.transform, "y", target.sprite.transform.y - target.sprite.h*2, 6, "linear"),
							Ease(target.sprite.transform, "y", target.sprite.transform.y, 6, "quad"),
							Animate(target.sprite, "crouch"),
							Wait(0.1),
							Animate(target.sprite, "victory"),
							Wait(0.3),
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
				Action(),
				0.3
			)
		)
		table.insert(actions, returnAction)
	end

	if next(actions) == nil then
		table.insert(actions, target:takeDamage(self.stats, false, knockbackActionFun))
		table.insert(actions, returnAction)
	end
	return Parallel(actions)
end
