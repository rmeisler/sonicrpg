local WeaponType = require "util/WeaponType"
local ItemType = require "util/ItemType"
local EventType = require "util/EventType"

return {
	name = "Slapping Glove",
	desc = "A posh glove, perfect for slapping.",
	type = ItemType.Weapon,
	subtype = WeaponType.Sword,
	usableBy = {"antoine"},
	sprite = "sword",
	color = {200,200,0,255},
	stats = {
		attack = 3
	}
}
