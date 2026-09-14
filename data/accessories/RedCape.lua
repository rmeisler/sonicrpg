local ItemType = require "util/ItemType"

return {
	name = "Red Cape",
	desc = "Increases chance to dodge.",
	type = ItemType.Accessory,
	usableBy = {"bunny", "antoine", "sally", "sonic", "b", "tails", "rotor", "logan"},
	stats = {
		speed = 10,
	}
}
