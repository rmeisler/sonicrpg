local WeaponType = require "util/WeaponType"
local ItemType = require "util/ItemType"
local EventType = require "util/EventType"

return {
	name = "Great Gloves",
	desc = "Elegantly stitched gloves from the Great War.",
	type = ItemType.Weapon,
	subtype = WeaponType.Sword,
	usableBy = {"sonic"},
	sprite = "sword",
	color = {200,200,0,255},
	stats = {
		attack = 6
	}
}
