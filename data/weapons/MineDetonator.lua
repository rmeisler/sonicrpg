local WeaponType = require "util/WeaponType"
local ItemType = require "util/ItemType"
local EventType = require "util/EventType"

return {
	name = "Mine Detonator",
	desc = "Allows you to use mines in battle.",
	type = ItemType.Weapon,
	subtype = WeaponType.Sword,
	usableBy = {"sally"},
	stats = {
		attack = 5
	}
}
