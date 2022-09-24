local WeaponType = require "util/WeaponType"
local ItemType = require "util/ItemType"

return {
	name = "Backpack",
	desc = "Allows you to use Power Rings in battle.",
	type = ItemType.Armor,
	usableBy = {"sonic"},
	stats = {
		defense = 1,
		speed = -1,
	}
}
