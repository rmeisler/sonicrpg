local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"
local WaitForFrame = require "actions/WaitForFrame"
local MessageBox = require "actions/MessageBox"
local PlayAudio = require "actions/PlayAudio"
local Do = require "actions/Do"

local PressX = require "data/battle/actions/PressX"
local OnHitEvent = require "data/battle/actions/OnHitEvent"

local SpriteNode = require "object/SpriteNode"

local Layout = require "util/Layout"
local Transform = require "util/Transform"

return function(self, target)
	local numOfExtPieces = (self.sprite.transform.x - target.sprite.transform.x - 32) / 3
	local dy = (target.sprite.transform.y - self.sprite.transform.y - 16) / numOfExtPieces
	local lastXForm = Transform.from(self.sprite.transform)
	lastXForm.x = lastXForm.x - 6
	lastXForm.y = lastXForm.y + 15
	
	local extArm = SpriteNode(
		self.scene,
		Transform(lastXForm.x - 16, lastXForm.y - 16, 2, 2),
		self.sprite.color,
		"extenderarm",
		nil,
		nil,
		"sprites"
	)
	extArm:setAnimation("extendleft")
	extArm.sortOrderY = 600
	
	self.extenderOut = true
	
	local extPieceActions = {}
	local extPieces = {}
	for i=1,numOfExtPieces do
		local extObject = SpriteNode(
			self.scene,
			Transform.from(lastXForm),
			self.sprite.color,
			"extender",
			nil,
			nil,
			"sprites"
		)
		extObject.visible = false
		table.insert(extPieces, extObject)
		
		if i % 10 == 0 or i == numOfExtPieces then
			table.insert(extPieceActions,
				Do(function()
					for j=i-(9 - (i % 10)),i do
						extPieces[j].visible = self.extenderOut
						extArm.transform.x = extArm.transform.x + (self.extenderOut and -3 or 3)
						extArm.transform.y = extArm.transform.y + (self.extenderOut and dy or -dy)
					end
				end))
			table.insert(extPieceActions, Wait(0.01))
		end
		
		lastXForm.x = lastXForm.x - 3
		lastXForm.y = lastXForm.y + dy
	end
	
	-- Smack
	table.insert(
		extPieceActions,
		Animate(function()
			local xform = Transform(
				target.sprite.transform.x,
				target.sprite.transform.y,
				3,
				3
			)
			return SpriteNode(target.scene, xform, nil, "smack", nil, nil, "ui"), true
		end, "idle")
	)
	
	-- Create reverse action
	local reversed = {}
	for _, action in pairs(extPieceActions) do
		table.insert(reversed, 1, action)
	end
	
	-- Invokable by swatbot if escaped
	self.reverseAnimation = Serial {
		Do(function()
			self.extenderOut = false
		end),
		Serial(reversed),
		Do(function()
			-- Remove arm sprites and reset battle options
			for _, piece in pairs(extPieces) do
				piece:remove()
			end
			extArm:remove()
			
			self.options = self.origOptions
			self.sprite:setAnimation("idle")
			self.reverseAnimation = nil
			target.state = self.STATE_IDLE
		end)
	}
	
	-- Save prev anim
	target.prevAnim = target.sprite.selected
	target.state = target.STATE_IMMOBILIZED
	
	return Serial {
		Animate(self.sprite, "extend"),
		
		-- Extend arm toward enemy
		Serial(extPieceActions),
		
		PlayAudio("sfx", "smack", 1.0, true),
		Animate(target.sprite, "hurt"),
		
		Do(function()
			target.immobilizedBy = "bunny"
		
			-- Update battle menu
			self.origOptions = self.options
			self.options = {
				{Layout.Text("Hold"),
					choose = function(menu)
						menu:close()
						
						self.scene:run {
							menu,
							Do(function()
								self:endTurn()
							end)
						}
					end},
				{Layout.Text("Release"),
					choose = function(menu)
						menu:close()
						
						-- Release anim
						self.scene:run {
							Parallel {
								menu,
								self.reverseAnimation
							},
							
							Do(function()
								target.sprite:setAnimation("idle")
								target.state = target.STATE_IDLE
								target.chanceToEscape = nil
								self:endTurn()
							end)
						}
					end}
			}
		end),
		
		MessageBox {
			message=target.name.." is immobilized!",
			rect=MessageBox.HEADLINER_RECT,
			closeAction=Wait(0.6)
		}
	}
end
