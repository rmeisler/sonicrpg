local WeaponType = require "util/WeaponType"
local ItemType = require "util/ItemType"
local EventType = require "util/EventType"

return {
	name = "Mecha",
	desc = "Robotic arm.",
	type = ItemType.Weapon,
	subtype = WeaponType.Sword,
	sprite = "sword",
	usableBy = {"bunny"},
	color = {200,200,0,255},
	stats = {
		attack = 5,
		defense = 5
	}
}
