local ItemType = require "util/ItemType"

return {
	name = "Lucky Coin",
	desc = "50% more time to trigger timed-events in battle.",
	type = ItemType.Accessory,
	usableBy = {"sonic", "sally", "rotor", "bunny", "antoine"},
	stats = {},
	showX = true,
	showZ = true
}
