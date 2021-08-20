local WeaponType = require "util/WeaponType"
local ItemType = require "util/ItemType"
local EventType = require "util/EventType"

return {
	name = "Thick Gloves",
	desc = "Gloves made of thick leather.",
	type = ItemType.Weapon,
	subtype = WeaponType.Sword,
	usableBy = {"sonic"},
	sprite = "sword",
	color = {200,200,0,255},
	stats = {
		attack = 3
	}
}
