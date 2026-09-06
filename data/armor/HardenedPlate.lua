local WeaponType = require "util/WeaponType"
local ItemType = require "util/ItemType"

return {
	name = "Hardened Plate",
	desc = "Extra tough armor, crafted by Rotor for B.",
	type = ItemType.Armor,
	usableBy = {"b"},
	stats = {
		defense = 8
	}
}
