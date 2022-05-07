local ItemType = require "util/ItemType"

return {
	name = "Antigrav Shoes",
	desc = "Grants 'Antigrav' skill",
	type = ItemType.Legs,
	color = {50,50,50,255},
	usableBy = {"sonic", "sally", "antoine"},
	skill = require "data/battle/skills/Antigrav"
	stats = {
		defense = 1
	}
}
