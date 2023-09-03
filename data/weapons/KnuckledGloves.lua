local WeaponType = require "util/WeaponType"
local ItemType = require "util/ItemType"
local EventType = require "util/EventType"

return {
	name = "Knuckled Gloves",
	desc = "White mittens with conical extrusions...",
	type = ItemType.Weapon,
	subtype = WeaponType.Sword,
	icon = "icon_attack",
	cost = {
		gear = 100,
		emerald = 1
	},
	event = {
		type = EventType.X,
		action = function()
			return require "data/battle/actions/Leach"
		end
	},
	sprite = "sword",
	color = {200,200,0,255},
	stats = {
		attack = 10
	}
}
