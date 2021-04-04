local Menu = require "actions/Menu"
local Do = require "actions/Do"
local BlockPlayer = require "actions/BlockPlayer"
local Serial = require "actions/Serial"
local MessageBox = require "actions/MessageBox"
local Action = require "actions/Action"

local Layout = require "util/Layout"
local Transform = require "util/Transform"

local Savescreen = require "object/Savescreen"
local Player = require "object/Player"
local NPC = require "object/NPC"

local SavePoint = class(NPC)

function SavePoint:construct(scene, layer, object)
    self.ghost = true
	self.alignment = NPC.ALIGN_BOTLEFT

	NPC.init(self)

	self:addHandler("collision", SavePoint.touch, self)
	self:addInteract(SavePoint.savePrompt)
	
	if self.scene.lastSpawnPoint == self.name then
		self.scene.player = Player(scene, layer, table.clone(object))
	end
end

function SavePoint:update(dt)
	self.sprite:setAnimation("idle")
	NPC.update(self, dt)
end

function SavePoint:touch(prevState)
	self.sprite:setAnimation("activated")
	if prevState == NPC.STATE_IDLE then
		self.scene.audio:playSfx("save")
	end
end

function SavePoint:savePrompt()
	self.scene:run(BlockPlayer {
		Menu {
			layout = Layout {
				{Layout.Text("Would you like to save?"), selectable = false},
				{Layout.Text("Yes"), choose = function(menu)
					menu:close()
					self.scene:run {
						menu,
						Savescreen {
							scene = self.scene,
							spawnPoint = self.name
						}
					}
				end},
				{Layout.Text("No"), choose = function(menu) menu:close() end},
				colWidth = 200
			},
			transform = Transform(love.graphics.getWidth()/2, love.graphics.getHeight()/2 + 30),
			selectedRow = 2,
			cancellable = true
		},
		Do(function()
            self.scene.player.hidekeyhints[tostring(self)] = nil
        end)
	})
end

function SavePoint:onScan()
	return Serial {
		MessageBox {
			message="Nicole: {p50}.{p50}.{p50}.{p50}",
			blocking=true,
			closeAction=Action()
		},
		MessageBox {
			message="Nicole: Interact with this surreal device to save your game{p50}, Sally.",
			blocking=true,
			textSpeed = 4
		},
		MessageBox {
			message="Sally: Save my \"game\"? {p50}What are you talking about, Nicole?",
			blocking=true,
			textSpeed = 4
		},
	}
end


return SavePoint
