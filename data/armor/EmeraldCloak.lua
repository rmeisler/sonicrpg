local ItemType = require "util/ItemType"

return {
	name = "Emerald Cloak",
	desc = "A magical cloak from the distant past.",
	type = ItemType.Armor,
	color = {50,50,50,255},
	usableBy = {"tails", "b"},
	regen = {stat = "sp", per_turn = 1},
	stats = {
		defense = 4
	}
}
