local MessageBox = require "actions/MessageBox"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Animate = require "actions/Animate"
local Do = require "actions/Do"
local Action = require "actions/Action"
local Menu = require "actions/Menu"
local PlayAudio = require "actions/PlayAudio"

local Layout = require "util/Layout"
local Transform = require "util/Transform"

local NPC = require "object/NPC"

local Computer = class(NPC)

function Computer:construct(scene, layer, object)
	NPC.init(self)

	object.properties.sprite = nil
	object.properties.appearAfter = nil
	
	if GameState:isFlagSet(self) and self.sprite then
		self.sprite:setAnimation("open")
	end

	self:addInteract(Computer.use)
end

function Computer:use()
	if self.interacting or self.disabled then
		return
	end
	self.interacting = true

	local leaderMem = GameState.party[GameState.leader]
	if GameState.leader == "sally" then
		if self.object.properties.interface and GameState:isFlagSet(self) then
			self.specialHintPlayer = nil
			self.scene.player:removeKeyHint()
			
			local path = self.object.properties.interface:match("(actions/[%w%d_]+)%.lua")
			self.scene:run {
				require("maps/"..path)(self),
				Do(function()
					self.interacting = false
				end)
			}
		else
			self.scene:run {
				MessageBox {
					message=leaderMem.name..": I should be able to crack this using Nicole.",
					blocking=true
				},
				Do(function()
					self.interacting = false
				end)
			}
		end
	elseif GameState.leader == "bunny" then
		self.scene:run {
			MessageBox {
				message=leaderMem.name..": Oh my stars{p50}, this stuff looks complicated!",
				blocking=true
			},
			Do(function()
				self.interacting = false
			end)
		}
	elseif GameState.leader == "sonic" then
		self.scene:run {
			MessageBox {
				message=leaderMem.name..": This is really more of Sal's domain...",
				blocking=true
			},
			Do(function()
				self.interacting = false
			end)
		}
	elseif GameState.leader == "antoine" then
		self.scene:run {
			MessageBox {
				message=leaderMem.name..": This is not for me, I am thinking...",
				blocking=true
			},
			Do(function()
				self.interacting = false
			end)
		}
	end
end

function Computer:onScan()
	if GameState:isFlagSet(self) or self.disabled then
		return Action()
	end
	
	if self.object.properties.scanAction then
	    local spriteActions = Action()
		if self.sprite then
			spriteActions = Serial {
				Animate(self.sprite, "auth"),
				Do(function() self.sprite:setAnimation("auth_idle") end)
			}
		end
		return Serial {
			Parallel {
				spriteActions,
				MessageBox {
					message="Nicole: Accessing{p50}, Sally.",
					blocking=true,
					textSpeed=4,
					sfx="nicolebeep"
				}
			},
			
			assert(loadstring(self.object.properties.scanAction))()(self),
		}
	elseif self.object.properties.errorAction then
		return Serial {
			Parallel {
				Serial {
					Animate(self.sprite, "auth"),
					Do(function() self.sprite:setAnimation("auth_idle") end)
				},
				MessageBox {
					message="Nicole: Accessing{p50}, Sally.",
					blocking=true,
					textSpeed=4,
					sfx="nicolebeep"
				}
			},
			MessageBox {
				message="Nicole: I am unable to bypass this security system...",
				blocking=true,
				textSpeed=4,
				sfx="error"
			},
			
			assert(loadstring(self.object.properties.errorAction))()(self),
			
			Do(function()
				-- Set flag so this persists
				GameState:setFlag(self)
			end)
		}
	elseif self.object.properties.interface then
		return Serial {
			Parallel {
				Serial {
					Animate(self.sprite, "auth"),
					Do(function() self.sprite:setAnimation("auth_idle") end)
				},
				MessageBox {
					message="Nicole: Accessing{p50}, Sally.",
					blocking=true,
					textSpeed=4,
					sfx="nicolebeep"
				}
			},
			MessageBox {
				message="Nicole: I am unable to bypass this security system...",
				blocking=true,
				textSpeed=4,
				sfx="error"
			},
			MessageBox {
				message="Nicole: ...but you now have access to the "..self.object.properties.interfaceName.."...",
				blocking=true,
				textSpeed=4
			},
			Do(function()
				-- Set flag so this persists
				GameState:setFlag(self)
			end)
		}
	else
		local onscan = Action()
		if self.object.properties.onscan then
			local path = self.object.properties.onscan:match("(actions/[%w%d_]+)%.lua")
			onscan = require("maps/"..path)(self)
		end
		return Serial {
			Parallel {
				Serial {
					Animate(self.sprite, "auth"),
					Do(function() self.sprite:setAnimation("auth_idle") end)
				},
				MessageBox {
					message="Nicole: Accessing{p50}, Sally.",
					blocking=true,
					textSpeed=4,
					sfx="nicolebeep"
				}
			},
			Parallel {
				Serial {
					Animate(self.sprite, "hacked"),
					Do(function() self.sprite:setAnimation("hacked_idle") end)
				},
				MessageBox {
					message="Nicole: Security system bypassed.",
					blocking=true,
					textSpeed=4
				}
			},
			
			onscan,
			
			Do(function()
				-- Set flag so this persists
				GameState:setFlag(self)
			end)
		}
	end
end


return Computer
