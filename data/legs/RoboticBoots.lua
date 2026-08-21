local ItemType = require "util/ItemType"

return {
	name = "Robotic Boots",
	desc = "Boots built from Swatbot parts.",
	type = ItemType.Legs,
	color = {50,50,50,255},
	usableBy = {"sonic", "sally", "antoine", "rotor", "logan"},
	stats = {
		defense = 5,
		speed = -1
	}
}
