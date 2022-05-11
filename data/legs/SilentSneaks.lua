local ItemType = require "util/ItemType"

return {
	name = "Silent Sneaks",
	desc = "Bots can't hear you",
	type = ItemType.Legs,
	color = {50,50,50,255},
	usableBy = {"sonic"},
	stats = {
		speed = 1
	}
}
