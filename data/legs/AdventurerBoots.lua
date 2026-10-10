local ItemType = require "util/ItemType"

return {
	name = "Adventurer Boots",
	desc = "Upgraded attack and can counter on dodge.",
	type = ItemType.Legs,
	color = {50,50,50,255},
	usableBy = {"sally"},
	stats = {
		attack = 6,
		defense = 1,
		speed = 2
	}
}
