local MessageBox = require "actions/MessageBox"
local Menu = require "actions/Menu"
local Serial = require "actions/Serial"
local Action = require "actions/Action"
local Do = require "actions/Do"
local BlockPlayer = require "actions/BlockPlayer"

local Transform = require "util/Transform"
local Layout = require "util/Layout"

local NPC = require "object/NPC"

local Pickup = class(NPC)

function Pickup:construct(scene, layer, object)
	self.ghost = true
	self.alignment = NPC.ALIGN_BOTLEFT

	self.item = require("data/items/"..object.properties.item)

	self.sprite:setAnimation("idle")
	object.properties.alignOffsetX = 32.0

	NPC.init(self)

	self:addInteract(Pickup.grab)
end

function Pickup:grab()
	self.scene.player.hidekeyhints[tostring(self)] = self
	
	self.scene:run(BlockPlayer {
        MessageBox {
            message = string.format("Rotor: That's a %s! {p30}%s", self.item.name, self.item.rotor)
        },
        Menu {
            layout = Layout {
                {Layout.Text(string.format("Take %s?", self.item.name)), selectable = false},
                {Layout.Text("Yes"), noChooseSfx = true, choose = function(menu)
                    menu:close()
                    GameState:grantItem(self.item, 1)
                    self.scene:run {
                        menu,
                        Do(function() self:remove() end),
                        MessageBox {
                            message = string.format("You received a %s!", self.item.name),
                            blocking = true,
                            sfx = "choose",
                            textSpeed = 7
                        }
                    }
                end},
                {Layout.Text("No"), choose = function(menu)
					menu:close()
					self.scene:run {
						menu,
						Do(function()
							self.scene.player.hidekeyhints[tostring(self)] = nil
						end)
					}
				end},
            },
            transform = Transform(love.graphics.getWidth()/2, love.graphics.getHeight()/2 + 30),
            selectedRow = 2
        }
    })
end


return Pickup
