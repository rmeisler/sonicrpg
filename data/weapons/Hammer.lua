local WeaponType = require "util/WeaponType"
local ItemType = require "util/ItemType"
local EventType = require "util/EventType"

return {
	name = "Hammer",
	desc = "Rotor's favorite tool",
	type = ItemType.Weapon,
	subtype = WeaponType.Sword,
	usableBy = {"rotor"},
	sprite = "sword",
	color = {200,200,0,255},
	stats = {
		attack = 1
	}
}
