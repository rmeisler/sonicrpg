local Serial = require "actions/Serial"
local Do = require "actions/Do"
local MessageBox = require "actions/MessageBox"
local Wait = require "actions/Wait"
local Action = require "actions/Action"
local PlayAudio = require "actions/PlayAudio"
local Animate = require "actions/Animate"
local Ease = require "actions/Ease"
local Parallel = require "actions/Parallel"

local Transform = require "util/Transform"

local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local Smack = require "data/monsters/actions/Smack"

return {
	name = "Mecha Arm",
	altName = "Mecha Arm",
	sprite = "sprites/mechaarm",
	
	mockSprite = "sprites/mechaarmbattle",
	mockSpriteOffset = Transform(-300, -100),

	stats = {
		xp    = 10,
		maxhp = 150,
		attack = 15,
		defense = 15,
		speed = 2,
		focus = 1,
		luck = 1,
	},

	run_chance = 0.7,

	coin = 0,

	drops = {
		
	},

	behavior = function (self, target)
		local grabProgression = {
			sally = {
				{"dive1", Transform()},
				{"grab1_1", Transform(-73, 0)},
				{"grab1_2", Transform(-92, -10)},
				{"grab1_3", Transform(-170, -26)},
				{"grab1_4", Transform(-259, -20)},
				{"grab1_finish", Transform(-356, 50)}
			},
			sonic = {
				{"dive2", Transform()},
				{"grab2_1", Transform()},
				{"grab2_2", Transform(-74, -17)},
				{"grab2_3", Transform(-121, -24)},
				{"grab2_4", Transform(-259, -33)},
				{"grab2_finish", Transform(-356, -44)}
			},
		}
		
		if self.grabbed then
			-- Progress the grab
			if self.grabProgress < #(grabProgression[self.grabbed]) - 1 then
				self.grabProgress = self.grabProgress + 1
				
				local progressStep = grabProgression[self.grabbed][self.grabProgress]
				self.mockSprite:setAnimation(progressStep[1])
				
				local targetSprite = self.scene.partyByName[self.grabbed].sprite
				targetSprite.transform.x = self.grabbedXform.x + progressStep[2].x
				targetSprite.transform.y = self.grabbedXform.y + progressStep[2].y
			else
				self.grabProgress = self.grabProgress + 1

				local progressStep = grabProgression[self.grabbed][self.grabProgress]
				local targetMem = self.scene.partyByName[self.grabbed]
				local targetSprite = targetMem.sprite
				targetSprite.transform.x = self.grabbedXform.x + progressStep[2].x
				targetSprite.transform.y = self.grabbedXform.y + progressStep[2].y
			
				local allDead = true
				for _, mem in pairs(self.scene.party) do
					if mem.id ~= self.grabbed then
						allDead = allDead and (mem.state == targetMem.STATE_DEAD)
					end
				end
				
				local endAction = self.scene:earlyExit()
				if allDead then
					endAction = Action()
				end

				return Serial {
					Parallel {
						Animate(self.mockSprite, progressStep[1]),
						Ease(targetSprite.transform, "x", self.grabbedXform.x - 456, 2, "linear"),
						Ease(targetSprite.color, 4, 0, 2, "linear")
					},
					Do(function()
						targetMem.hp = 0
						targetMem.state = targetMem.STATE_DEAD
						self.mockSprite:remove()
					end),
					MessageBox {message="Mecha Arm disappeared...", rect=MessageBox.HEADLINER_RECT, closeAction=Wait(1)},
					endAction,
					Do(function()
						-- This needs to be here for unknown reasons to make earlyExit work...
					end)
				}
			end
		else
			self.grabbed = target.id
			self.grabProgress = 1
			
			-- Mechaarm is confused, do nothing
			local targetMem = self.scene.partyByName[self.grabbed]
			if not targetMem then
				return Action()
			end
			
			local targetSprite = targetMem.sprite
			self.grabbedXform = Transform(targetSprite.transform.x, targetSprite.transform.y)
			
			local progressStep = grabProgression[self.grabbed][self.grabProgress]
			
			self.noHurtAnim = true
			
			return Serial {
				Animate(self.mockSprite, progressStep[1]),
				PlayAudio("sfx", "smack2", 1.0, true),
				Do(function()
					self.grabProgress = self.grabProgress + 1
					
					progressStep = grabProgression[self.grabbed][self.grabProgress]
					self.mockSprite:setAnimation(progressStep[1])
					
					self.grabProgress = self.grabProgress + 1
					
					target.state = target.STATE_IMMOBILIZED
				end),
				Animate(target.sprite, "hurt"),
				MessageBox {message="Mecha Arm grabbed "..target.name.."!", rect=MessageBox.HEADLINER_RECT, closeAction=Wait(1)},
			}
		end
	end,
	
	onDead = function(self)
		return Action()
	end
}