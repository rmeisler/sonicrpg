local ItemType = require "util/ItemType"

return {
	name = "Boots",
	desc = "A pair of knee-high boots.",
	type = ItemType.Legs,
	color = {50,50,50,255},
	usableBy = {"sally", "antoine"},
	stats = {
		defense = 1
	}
}
