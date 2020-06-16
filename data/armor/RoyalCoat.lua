local ItemType = require "util/ItemType"

return {
	name = "Royal Coat",
	desc = "The coat worn by members of King Max's royal guard.",
	type = ItemType.Armor,
	color = {50,50,50,255},
	usableBy = {"antoine"},
	stats = {
		defense = 2
	}
}
