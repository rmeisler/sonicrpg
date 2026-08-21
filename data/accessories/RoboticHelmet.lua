local ItemType = require "util/ItemType"

return {
	name = "Robotic Helmet",
	desc = "Helmet built from Swatbot parts.",
	type = ItemType.Accessory,
	usableBy = {"sonic", "sally", "antoine", "rotor", "logan"},
	stats = {
		defense = 3,
		speed = -1
	}
}
