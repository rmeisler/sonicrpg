local ItemType = require "util/ItemType"

return {
	name = "Vest",
	desc = "A stylish blue vest.",
	type = ItemType.Armor,
	color = {50,50,50,255},
	usableBy = {"sally"},
	stats = {
		defense = 2
	}
}
