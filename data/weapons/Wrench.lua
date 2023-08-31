local WeaponType = require "util/WeaponType"
local ItemType = require "util/ItemType"
local EventType = require "util/EventType"

return {
	name = "Wrench",
	desc = "A well worn, steel wrench.",
	type = ItemType.Weapon,
	subtype = WeaponType.Sword,
	usableBy = {"rotor"},
	sprite = "sword",
	color = {200,200,0,255},
	stats = {
		attack = 4
	}
}
