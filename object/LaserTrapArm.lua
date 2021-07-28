local MessageBox = require "actions/MessageBox"
local Do = require "actions/Do"
local Ease = require "actions/Ease"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local Repeat = require "actions/Repeat"
local Executor = require "actions/Executor"
local Menu = require "actions/Menu"
local BlockPlayer = require "actions/BlockPlayer"
local Action = require "actions/Action"

local Layout = require "util/Layout"
local Transform = require "util/Transform"

local ExtPost = require "object/ExtPost"

local LaserTrapArm = class(ExtPost)

function LaserTrapArm:construct(scene, layer, object)
	self.ghost = true
	self.snapToObject = true
	self:addInteract(LaserTrapArm.onInteract)
end

function LaserTrapArm:onInteract()
	local leaderMem = GameState.party[GameState.leader]
	if GameState.leader == "sally" then
		self.scene:run {
			MessageBox {
				message=leaderMem.name..": I should be able to crack this using Nicole.",
				blocking=true
			},
			Do(function()
				self:refreshKeyHint()
			end)
		}
	elseif GameState.leader == "bunny" then
		self.scene:run {
			MessageBox {
				message=leaderMem.name..": Oh my stars{p50}, this stuff looks complicated!",
				blocking=true
			},
			Do(function()
				self:refreshKeyHint()
			end)
		}
	elseif GameState.leader == "sonic" then
		self.scene:run {
			MessageBox {
				message=leaderMem.name..": This is really more of Sal's domain...",
				blocking=true
			},
			Do(function()
				self:refreshKeyHint()
			end)
		}
	elseif GameState.leader == "antoine" then
		self.scene:run {
			MessageBox {
				message=leaderMem.name..": This is not for me, I am thinking...",
				blocking=true
			},
			Do(function()
				self:refreshKeyHint()
			end)
		}
	end
end

function LaserTrapArm:onScan()
	local extraAction = Action()
    if not GameState:isFlagSet(self) then
        extraAction = MessageBox {message="Nicole: Hacking laser turret, {p40}Sally...", textspeed=4}
        GameState:setFlag(self)
    end
    
    return BlockPlayer {
        extraAction,
        Menu {
            layout = Layout {
                {Layout.Text{text="Reconfigure Laser Turret", color={255,255,0,255}}, selectable = false},
                {Layout.Text("Always-On"), choose = function(menu)
                    menu:close()
					self.parentTrap.alwaysOn = true
					self.parentTrap.deactivated = false
					self.parentTrap:lasersOn()
                end},
                {Layout.Text("Fire-When-Close"), choose = function(menu)
                    menu:close()
					self:disappearLasers()
					self.parentTrap.alwaysOn = false
					self.parentTrap.deactivated = false
                end},
                {Layout.Text("Deactivate"), choose = function(menu)
                    menu:close()
					self:disappearLasers()
					self.parentTrap.alwaysOn = false
					self.parentTrap.deactivated = true
                end},
                {Layout.Text("Keep current settings"), choose = function(menu)
                    menu:close()
                end},
            },
            cancellable = true,
            selectedRow = 2,
            transform = Transform(love.graphics.getWidth()/2 + 150, love.graphics.getHeight()/2 + 30)
        }
    }
end

function LaserTrapArm:disappearLasers()
	if self.parentTrap.alwaysOn then
		self.parentTrap.laser1:run {
			Do(function()
				self.parentTrap.laser1.sprite.transform.ox = self.parentTrap.laser1.sprite.w
				self.parentTrap.laser1.x = self.parentTrap.laser1.x + self.parentTrap.laserScale * self.scene:getTileWidth()
			end),
			Ease(self.parentTrap.laser1.sprite.transform, "sx", 0, 5)
		}
		self.parentTrap.laser2:run {
			Do(function()
				self.parentTrap.laser2.sprite.transform.ox = 0
				self.parentTrap.laser2.x = self.parentTrap.laser2.x - self.parentTrap.laserScale * self.scene:getTileWidth()
			end),
			Ease(self.parentTrap.laser2.sprite.transform, "sx", 0, 5)
		}
	end
end


return LaserTrapArm
