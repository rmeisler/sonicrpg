local ItemType = require "util/ItemType"

return {
	name = "Lucky Coin",
	desc = "Increases luck.",
	type = ItemType.Accessory,
	usableBy = {"sonic", "sally", "rotor", "bunny", "antoine", "logan", "tails", "babyt", "b"},
	stats = {luck=1},
	showX = true,
	showZ = true
}
