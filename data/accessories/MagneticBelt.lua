local WeaponType = require "util/WeaponType"
local ItemType = require "util/ItemType"

return {
	name = "Magnetic Belt",
	desc = "Draws bot attacks toward you.",
	type = ItemType.Accessory,
	usableBy = {"sonic", "sally", "rotor", "bunny", "antoine"},
	stats = {
		defense = 4,
		speed = -2,
	}
}
