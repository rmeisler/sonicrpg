local Menu = require "actions/Menu"
local Do = require "actions/Do"
local BlockPlayer = require "actions/BlockPlayer"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local MessageBox = require "actions/MessageBox"
local Action = require "actions/Action"
local Repeat = require "actions/Repeat"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"

local Layout = require "util/Layout"
local Transform = require "util/Transform"

local Savescreen = require "object/Savescreen"
local Player = require "object/Player"
local NPC = require "object/NPC"

local Laser = class(NPC)

function Laser:construct(scene, layer, object)
    self.alignment = NPC.ALIGN_BOTLEFT
	
	NPC.init(self)

	self:addHandler("collision", Laser.touch, self)
end

function Laser:touch(prevState)
	if prevState == NPC.STATE_IDLE then
		local pushback = -20
		if self.y + self.object.height > self.scene.player.y then
			pushback = 20
		end
	
		self.scene:run {
			BlockPlayer {
				Do(function()
					self.scene.player.state = "shock"
				end),
				PlayAudio("sfx", "shocked", 1.0, true),
				Repeat(Serial {
					Do(function()
						self.scene.player.sprite:setInvertedColor()
					end),
					Wait(0.1),
					Do(function()
						self.scene.player.sprite:removeInvertedColor()
					end),
					Wait(0.1),
				}, 3),
			},
			
			Ease(self.scene.player, "y", self.scene.player.y + 60, 8, "linear"),
			
			Do(function()
				self.scene.player.state = "idledown"
			end)
		}
	end
end



return Laser
