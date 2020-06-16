local WeaponType = require "util/WeaponType"
local ItemType = require "util/ItemType"

return {
	name = "Backpack",
	desc = "Allows you to carry x1 Power Ring.",
	type = ItemType.Accessory,
	usableBy = {"sonic"},
	stats = {
		defense = 1,
		speed = -1,
	}
}
