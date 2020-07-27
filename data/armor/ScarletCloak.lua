local ItemType = require "util/ItemType"

return {
	name = "Scarlet Cloak",
	desc = "Makes you invisible to enemies on the map.",
	type = ItemType.Accessory,
	color = {50,50,50,255},
	usableBy = {"sonic"},
	stats = {
		defense = 1
	}
}
