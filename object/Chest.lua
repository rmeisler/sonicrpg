local MessageBox = require "actions/MessageBox"
local Serial = require "actions/Serial"
local Action = require "actions/Action"
local Do = require "actions/Do"

local Chest = class(require "object/ExtPost")

function Chest:construct(scene, layer, object)
	-- Remove properties that are not appropriate as items on Chest
	object.properties.sprite = nil
	object.properties.defaultAnim = nil
	object.properties.appearAfter = nil
	
	self.disappearOnGrabbed = object.properties.disappearOnGrabbed
	object.properties.disappearOnGrabbed = nil

	if GameState:isFlagSet(self) and self.sprite then
		self.sprite:setAnimation("open")
	end

	self:addInteract(Chest.open)
end

function Chest:requireLoot(name)
	for _, itemType in pairs {"items", "weapons", "armor", "accessories"} do
		local itemName = string.format("data/%s/%s", itemType, name)
		local status = pcall(require, itemName)
		if status then
			print("load item "..itemName)
			return require(itemName)
		else
			print("fail load item "..itemName)
		end
	end
	return nil
end

function Chest:open()
	local items = self.object.properties
	local msg = "Empty!"

	if not GameState:isFlagSet(self) then
		local contents = ""
		for k,v in pairs(items) do
			local item = self:requireLoot(k)
			GameState:grantItem(item, v)

			local name = item.name
			if v > 1 then
				contents = contents..tostring(v).." "..name.."s"
			else
				contents = contents.." a "..name
			end
			if next(items, k) then
				contents = contents.." and "
			end
		end
		msg = "You received "..contents.."!"
		
		self.scene.audio:playSfx("choose", nil, true)
		
		if self.sprite then
			self.sprite:setAnimation("open")
		end
		
		-- Set flag so this persists
		GameState:setFlag(self)
	end
	self.scene:run {
		MessageBox {
			message=msg,
			blocking=true
		},
		Do(function()
			if self.disappearOnGrabbed then
				self:remove()
			end
		end)
	}
end

function Chest:onScan()
	return Serial {
		MessageBox {
			message="Nicole: {p50}.{p50}.{p50}.{p50}",
			blocking=true,
			closeAction=Action()
		},
		MessageBox {
			message="Nicole: This is a chest{p50}, Sally.",
			blocking=true,
			textSpeed = 4
		},
	}
end


return Chest
