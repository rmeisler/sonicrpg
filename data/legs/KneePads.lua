local ItemType = require "util/ItemType"

return {
	name = "Knee Pads",
	desc = "A little goofy looking, but protective.",
	type = ItemType.Legs,
	color = {50,50,50,255},
	usableBy = {"sally", "sonic", "antoine", "rotor", "bunny"},
	stats = {
		defense = 3
	}
}
