local ItemType = require "util/ItemType"

return {
	name = "Lucky Coin",
	desc = "50% more time to trigger timed-events in battle.",
	type = ItemType.Accessory,
	usableBy = {"sonic", "sally", "rotor", "bunny", "antoine", "logan"},
	stats = {luck=1},
	showX = true,
	showZ = true
}
