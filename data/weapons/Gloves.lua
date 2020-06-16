local WeaponType = require "util/WeaponType"
local ItemType = require "util/ItemType"
local EventType = require "util/EventType"

return {
	name = "Gloves",
	desc = "Standard white gloves.",
	type = ItemType.Weapon,
	subtype = WeaponType.Sword,
	usableBy = {"sonic"},
	sprite = "sword",
	color = {200,200,0,255},
	stats = {
		attack = 1
	}
}
