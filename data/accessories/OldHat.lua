local ItemType = require "util/ItemType"

return {
	name = "Old Hat",
	desc = "This hat could stand to be cleaned...",
	type = ItemType.Accessory,
	color = {50,50,50,255},
	usableBy = {"rotor"},
	stats = {
		defense = 1
	}
}
