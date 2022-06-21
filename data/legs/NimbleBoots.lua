local ItemType = require "util/ItemType"

return {
	name = "Nimble Boots",
	desc = "Greatly increases your speed.",
	type = ItemType.Legs,
	color = {50,50,50,255},
	usableBy = {"sally", "antoine"},
	stats = {
		defense = 2,
		speed = 5
	}
}
