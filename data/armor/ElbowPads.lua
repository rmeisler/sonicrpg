local ItemType = require "util/ItemType"

return {
	name = "Elbow Pads",
	desc = "A little goofy looking, but protective.",
	type = ItemType.Armor,
	color = {50,50,50,255},
	usableBy = {"sally", "sonic", "antoine", "rotor", "bunny", "logan"},
	stats = {
		defense = 3
	}
}
